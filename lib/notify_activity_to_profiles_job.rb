class NotifyActivityToProfilesJob < Struct.new(:tracked_action_id, :target_profile_id)
  def perform
    profile = Profile.find(target_profile_id) unless target_profile_id.nil?
    tracked_action = ActionTracker::Record.find(tracked_action_id)
    tracked_action.user.each_friend do |friend|
      Delayed::Job.enqueue NotifyActivityJob.new(tracked_action_id, friend.id)
    end
    if profile.is_a?(Community)
      profile.each_member do |member|
        next if member == tracked_action.user
        Delayed::Job.enqueue NotifyActivityJob.new(tracked_action_id, member.id)
      end
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => profile)
    end
  end
end
