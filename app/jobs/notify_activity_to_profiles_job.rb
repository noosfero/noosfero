class NotifyActivityToProfilesJob < Struct.new(:tracked_action_id)
  NOTIFY_ONLY_COMMUNITY = [
    'add_member_in_community'
  ]

  NOT_NOTIFY_COMMUNITY = [
    'join_community'
  ]
  def perform
    return unless ActionTracker::Record.exists?(tracked_action_id)
    tracked_action = ActionTracker::Record.find(tracked_action_id)
    return unless tracked_action.user.present?
    target = tracked_action.target
    if target.is_a?(Community) && NOTIFY_ONLY_COMMUNITY.include?(tracked_action.verb)
      ActionTrackerNotification.create(:profile_id => target.id, :action_tracker_id => tracked_action.id)
      return
    end

    # Notify the user
    ActionTrackerNotification.create(:profile_id => tracked_action.user.id, :action_tracker_id => tracked_action.id)

    if target.is_a?(Scrap) && target.marked_people.present?
      # Notify only marked people
      ActionTrackerNotification.connection.execute("INSERT INTO action_tracker_notifications(profile_id, action_tracker_id) SELECT DISTINCT profiles.id, #{tracked_action.id} FROM profiles WHERE profiles.id IN (#{target.marked_people.map(&:id).join(',')})")
    else
      # Notify all owner followers
      ActionTrackerNotification.connection.execute("INSERT INTO action_tracker_notifications(profile_id, action_tracker_id) SELECT DISTINCT c.person_id, #{tracked_action.id} FROM profiles_circles AS p JOIN circles as c ON c.id = p.circle_id WHERE p.profile_id = #{tracked_action.user.id} AND (c.person_id NOT IN (SELECT atn.profile_id FROM action_tracker_notifications AS atn WHERE atn.action_tracker_id = #{tracked_action.id}))")
    end

    if tracked_action.user.is_a? Organization
      ActionTrackerNotification.connection.execute "insert into action_tracker_notifications(profile_id, action_tracker_id) " +
      "select distinct accessor_id, #{tracked_action.id} from role_assignments where resource_id = #{tracked_action.user.id} and resource_type='Profile' " +
      if tracked_action.user.is_a? Enterprise then "union select distinct person_id, #{tracked_action.id} from favorite_enterprise_people where enterprise_id = #{tracked_action.user.id}" else "" end
    end

    if target.is_a?(Community)
      ActionTrackerNotification.create(:profile_id => target.id, :action_tracker_id => tracked_action.id) unless NOT_NOTIFY_COMMUNITY.include?(tracked_action.verb)
      target_profile = target
    end

    if target.is_a?(Article) && target.profile.is_a?(Community)
      ActionTrackerNotification.create(:profile_id => target.profile.id, :action_tracker_id => tracked_action.id) unless NOT_NOTIFY_COMMUNITY.include?(tracked_action.verb)
      target_profile = target.profile
    end

    if target_profile.is_a? Profile
      # Notify all target followers. The target can be:
      # - If the target is a Community, the community itself
      # - If the target is an Article, the profile it was published in
      # TODO: What about other kinds of Organizations?
      ActionTrackerNotification.connection.execute("INSERT INTO action_tracker_notifications(profile_id, action_tracker_id) SELECT DISTINCT c.person_id, #{tracked_action.id} FROM profiles_circles AS p JOIN circles as c ON c.id = p.circle_id WHERE p.profile_id = #{target_profile.id} AND (c.person_id NOT IN (SELECT atn.profile_id FROM action_tracker_notifications AS atn WHERE atn.action_tracker_id = #{tracked_action.id}))")
    end

  end
end
