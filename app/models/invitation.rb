class Invitation < Task

  acts_as_having_settings :field => :data
  settings_items :message, :friend_name, :friend_email

  validates_presence_of :requestor_id

  validates_presence_of :target_id, :if => Proc.new{|invite| invite.friend_email.blank?}

  validates_presence_of :friend_email, :if => Proc.new{|invite| invite.target_id.blank?}
  validates_format_of :friend_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => Proc.new{|invite| invite.target_id.blank?}

  validates_presence_of :message, :if => Proc.new{|invite| invite.target_id.blank?}

  alias :person :requestor
  alias :person= :requestor=

  alias :friend :target
  alias :friend= :target=

  before_create do |task|
    if task.message && !task.message.match(/<url>/)
      task.message += Invitation.default_message_to_accept_invitation
    end
  end

  after_create do |task|
    TaskMailer.deliver_invitation_notification(task) unless task.friend
  end

  def validate
    super
    email = friend ? friend.user.email : friend_email
    if person && email && person.user.email == email
      self.errors.add_to_base(_("You can't invite youself"))
    end
  end

  # Returns <tt>false</tt>. Adding friends by itself does not trigger e-mail
  # sending.
  def sends_email?
    false
  end

  def self.invite(person, contacts_to_invite, message, profile)
    contacts_to_invite.each do |contact_to_invite|
      next if contact_to_invite == _("Firstname Lastname <friend@email.com>")

      contact_to_invite.strip!
      if match = contact_to_invite.match(/(.*)<(.*)>/) and match[2].match(Noosfero::Constants::EMAIL_FORMAT)
        friend_name = match[1].strip
        friend_email = match[2]
      elsif match = contact_to_invite.strip.match(Noosfero::Constants::EMAIL_FORMAT)
        friend_name = ""
        friend_email = match[0]
      else
        next
      end

      user = User.find_by_email(friend_email)

      task_args = if user.nil?
        {:person => person, :friend_name => friend_name, :friend_email => friend_email, :message => message}
      elsif !user.person.is_a_friend?(person)
        {:person => person, :target => user.person}
      end

      if !task_args.nil?
        if profile.person?
          InviteFriend.create(task_args)
        elsif profile.community?
          InviteMember.create(task_args.merge(:community_id => profile.id))
        else
          raise NotImplementedError, 'Don\'t know how to invite people to a %s' % profile.class.to_s
        end
      end
    end
  end

  def self.get_contacts(source, login, password, contact_list_id)
    contact_list = ContactList.find(contact_list_id)
    case source
    when "gmail"
      email_service = Contacts::Gmail.new(login, password)
    when "yahoo"
      email_service = Contacts::Yahoo.new(login, password)
    when "hotmail"
      email_service = Contacts::Hotmail.new(login, password)
    when "manual"
      #do nothing
    else
      raise NotImplementedError, 'Unknown source to get contacts'
    end
    if email_service
      contact_list.list = email_service.contacts.map { |contact| contact + ["#{contact[0]} <#{contact[1]}>"] }
      contact_list.fetched = true
      contact_list.save
    end
    contact_list.list
  end

  def self.join_contacts(manual_import_addresses, webmail_import_addresses)
    contacts = []
    if manual_import_addresses
      contacts += manual_import_addresses.is_a?(Array) ? manual_import_addresses : manual_import_addresses.split
    end
    if webmail_import_addresses
      contacts += webmail_import_addresses.is_a?(Array) ? webmail_import_addresses : webmail_import_addresses.split
    end
    contacts
  end

  def expanded_message
    msg = message
    msg = msg.gsub /<user>/, person.name
    msg = msg.gsub /<friend>/, friend_name.blank? ? friend_email : friend_name
    msg = msg.gsub /<environment>/, person.environment.name
    msg
  end

  def mail_template
    raise 'You should implement mail_template in a subclass'
  end

  def self.default_message_to_accept_invitation
    "\n\n" + _('To accept invitation, please follow this link: <url>')
  end
end
