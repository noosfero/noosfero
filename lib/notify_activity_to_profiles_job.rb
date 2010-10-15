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
      ActionTrackerNotification.create(:profile_id => target.id, :action_tracker_id => tracked_action.id)
      return
    end

    ActionTrackerNotification.create(:profile_id => tracked_action.user.id, :action_tracker_id => tracked_action.id)

    ActionTrackerNotification.connection.execute("insert into action_tracker_notifications(profile_id, action_tracker_id) select f.friend_id, #{tracked_action.id} from friendships as f where person_id=#{tracked_action.user.id} and f.friend_id not in (select atn.profile_id from action_tracker_notifications as atn where atn.action_tracker_id = #{tracked_action.id})")

    if target.is_a?(Community)
      ActionTrackerNotification.connection.execute("insert into action_tracker_notifications(profile_id, action_tracker_id) select distinct profiles.id, #{tracked_action.id} from role_assignments, profiles where profiles.type = 'Person' and profiles.id = role_assignments.accessor_id and profiles.id != #{tracked_action.user.id} and role_assignments.resource_type = 'Profile' and role_assignments.resource_id = #{target.id}")

      ActionTrackerNotification.create(:profile_id => target.id, :action_tracker_id => tracked_action.id) unless NOT_NOTIFY_COMMUNITY.include?(tracked_action.verb)
    end
  end
end
