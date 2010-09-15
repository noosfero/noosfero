class NotifyActivityToProfilesJob < Struct.new(:tracked_action_id, :target_profile_id)
  def perform
    profile = Profile.find(target_profile_id) unless target_profile_id.nil?
    tracked_action = ActionTracker::Record.find(tracked_action_id)
    tracked_action.user.each_friend do |friend|
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => friend)
    end
    if profile.is_a?(Community)
      profile.each_member do |member|
        next if member == tracked_action.user
        ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => member)
      end
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => profile)
    end
  end
end
