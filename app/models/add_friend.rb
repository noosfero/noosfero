class AddFriend < Task

  acts_as_having_settings :group_for_person, :group_for_friend, :field => :data

  validates_presence_of :requestor_id, :target_id

  alias :person :requestor
  alias :person= :requestor=

  alias :friend :target
  alias :friend= :target=

  def perform
    requestor.add_friend(target, group_for_person)
    target.add_friend(requestor, group_for_friend)
  end

  # Returns <tt>false</tt>. Adding friends by itself does not trigger e-mail
  # sending.
  def sends_email?
    false
  end

end
