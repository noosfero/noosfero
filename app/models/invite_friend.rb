class InviteFriend < Task

  acts_as_having_settings :group_for_person, :group_for_friend, :message, :friend_name, :friend_email, :field => :data

  validates_presence_of :requestor_id

  validates_presence_of :target_id, :if => Proc.new{|invite| invite.friend_email.blank? }

  validates_presence_of :friend_email, :if => Proc.new{|invite| invite.target_id.blank? }
  validates_format_of :friend_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => Proc.new{|invite| invite.target_id.blank? }

  validates_presence_of :message, :if => Proc.new{|invite| invite.target_id.blank? }
  validates_format_of :message, :with => /<url>/, :if => Proc.new{|invite| invite.target_id.blank? }

  alias :person :requestor
  alias :person= :requestor=

  alias :friend :target
  alias :friend= :target=

  after_create do |task|
    TaskMailer.deliver_invitation_notification(task) unless task.friend
  end

  def perform
    requestor.add_friend(target, group_for_person)
    target.add_friend(requestor, group_for_friend)
  end

  # Returns <tt>false</tt>. Adding friends by itself does not trigger e-mail
  # sending.
  def sends_email?
    false
  end

  def description
    _('%s wants to be your friend.') % [requestor.name]
  end

  def permission
    :manage_friends
  end
end
