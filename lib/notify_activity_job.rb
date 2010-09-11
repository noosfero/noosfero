class NotifyActivityJob < Struct.new(:tracked_action_id, :profile_id)
  def perform
    tracked_action = ActionTracker::Record.find(tracked_action_id)
    profile = Profile.find(profile_id)
    ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => profile)
  end
end
