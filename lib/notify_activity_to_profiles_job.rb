class NotifyActivityToProfilesJob < Struct.new(:tracked_action_id)
  NOTIFY_ONLY_COMMUNITY = [
    'add_member_in_community',
    'remove_member_in_community',
  ]

  NOT_NOTIFY_COMMUNITY = [
    'join_community',
    'leave_community',
  ]
  def perform
    tracked_action = ActionTracker::Record.find(tracked_action_id)
    target = tracked_action.target
    if target.is_a?(Community) && NOTIFY_ONLY_COMMUNITY.include?(tracked_action.verb)
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => target)
      return
    end

    ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => tracked_action.user)
    tracked_action.user.each_friend do |friend|
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => friend)
    end

    if target.is_a?(Community)
      target.each_member do |member|
        next if member == tracked_action.user
        ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => member)
      end
      ActionTrackerNotification.create(:action_tracker => tracked_action, :profile => target) unless NOT_NOTIFY_COMMUNITY.include?(tracked_action.verb)
    end
  end
end
