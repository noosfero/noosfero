class Invitation < Task

  settings_items :message, :friend_name, :friend_email

  validates_presence_of :requestor_id

  validates_presence_of :target_id, :if => Proc.new{|invite| invite.friend_email.blank?}

  validates :requestor, kind_of: {kind: Person}

  validates_presence_of :friend_email, :if => Proc.new{|invite| invite.target_id.blank?}
  validates_format_of :friend_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => Proc.new{|invite| invite.target_id.blank?}

  validates_presence_of :message, :if => Proc.new{|invite| invite.target_id.blank?}

  validate :not_invite_yourself

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
    TaskMailer.invitation_notification(task).deliver unless task.friend
  end

  def title
    _('Invitation')
  end

  def not_invite_yourself
    email = friend && friend.person? ? friend.user.email : friend_email
    if person && email && person.user.email == email
      self.errors.add(:base, _("You can't invite youself"))
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
      find_by_profile_id = false
      if contact_to_invite.match(/^\d*$/)
        find_by_profile_id = true
      elsif match = contact_to_invite.match(/(.*)<(.*)>/) and match[2].match(Noosfero::Constants::EMAIL_FORMAT)
        friend_name = match[1].strip
        friend_email = match[2]
      elsif match = contact_to_invite.strip.match(Noosfero::Constants::EMAIL_FORMAT)
        friend_name = ""
        friend_email = match[0]
      else
        next
      end

      begin
        user = find_by_profile_id ? Person.find_by_id(contact_to_invite).user : User.find_by_email(friend_email)
      rescue
        user = nil
      end

      task_args = if user.nil? && !find_by_profile_id
        {:person => person, :friend_name => friend_name, :friend_email => friend_email, :message => message}
      elsif user.present? && !(user.person.is_a_friend?(person) && profile.person?)
        {:person => person, :target => user.person}
      end

      if profile.person?
        InviteFriend.create(task_args) if user.nil? || !user.person.is_a_friend?(person)
      elsif profile.community?
        InviteMember.create(task_args.merge(:community_id => profile.id)) if user.nil? || !user.person.is_member_of?(profile)
      else
        raise NotImplementedError, 'Don\'t know how to invite people to a %s' % profile.class.to_s
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

  def environment
    if self.requestor
      self.requestor.environment
    else
      nil
    end
  end

end
