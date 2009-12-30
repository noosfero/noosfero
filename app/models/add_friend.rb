class AddFriend < Task

  acts_as_having_settings :group_for_person, :group_for_friend, :field => :data

  validates_presence_of :requestor_id, :target_id

  validates_uniqueness_of :target_id, :scope => [ :requestor_id ]

 validates_length_of :group_for_person, :group_for_friend, :maximum => 150, :allow_nil => true

  alias :person :requestor
  alias :person= :requestor=

  alias :friend :target
  alias :friend= :target=

  def perform
    requestor.add_friend(target, group_for_person)
    target.add_friend(requestor, group_for_friend)
  end

  def description
    _('%s wants to be your friend.') % requestor.name
  end

  def permission
    :manage_friends
  end

  def target_notification_message
    description + "\n\n" +
    _('You need to login to %{system} in order to accept %{requestor} as your friend.') % { :system => target.environment.name, :requestor => requestor.name }
  end

end
