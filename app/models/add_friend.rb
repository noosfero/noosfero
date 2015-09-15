class AddFriend < Task

  settings_items :group_for_person, :group_for_friend

  validates_presence_of :requestor_id, :target_id

  validates_uniqueness_of :target_id, scope: [ :requestor_id, :status ], if: proc{ |t| t.status == Task::Status::ACTIVE }

  validates_length_of :group_for_person, :group_for_friend, :maximum => 150, :allow_nil => true

  alias :person :requestor
  alias :person= :requestor=

  alias :friend :target
  alias :friend= :target=

  validates :requestor, :kind_of => { :kind => Person }
  validates :target, :kind_of => { :kind => Person }

  after_create do |task|
    TaskMailer.invitation_notification(task).deliver unless task.friend
    remove_from_suggestion_list(task)
  end

  def perform
    target.add_friend(requestor, group_for_friend)
    requestor.add_friend(target, group_for_person)
  end

  def permission
    :manage_friends
  end

  def target_notification_description
    _('%{requestor} wants to be your friend.') % {:requestor => requestor.name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You need to login to %{system} in order to accept %{requestor} as your friend.') % { :system => target.environment.name, :requestor => requestor.name }
  end

  def title
    _("New friend")
  end

  def information
    {:message => _('%{requestor} wants to be your friend.') }
  end

  def accept_details
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def remove_from_suggestion_list(task)
    suggestion = task.requestor.suggested_profiles.find_by_suggestion_id task.target.id
    suggestion.disable if suggestion
  end
end
