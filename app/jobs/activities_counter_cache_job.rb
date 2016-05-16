class ActivitiesCounterCacheJob

  def perform
    person_activities_counts = ApplicationRecord.connection.execute("SELECT profiles.id, count(action_tracker.id) as count FROM profiles LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.user_id WHERE (action_tracker.created_at >= #{ApplicationRecord.connection.quote(ActionTracker::Record::RECENT_DELAY.days.ago.to_s(:db))}) AND ( (profiles.type = 'Person' ) ) GROUP BY profiles.id;")
    organization_activities_counts = ApplicationRecord.connection.execute("SELECT profiles.id, count(action_tracker.id) as count FROM profiles LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.target_id WHERE (action_tracker.created_at >= #{ApplicationRecord.connection.quote(ActionTracker::Record::RECENT_DELAY.days.ago.to_s(:db))}) AND ( (profiles.type = 'Community' OR profiles.type = 'Enterprise' OR profiles.type = 'Organization' ) ) GROUP BY profiles.id;")
    activities_counts = person_activities_counts.entries + organization_activities_counts.entries
    activities_counts.each do |count|
      update_sql = ApplicationRecord.__send__(:sanitize_sql, ["UPDATE profiles SET activities_count=? WHERE profiles.id=?;", count['count'].to_i, count['id'] ], '')
      ApplicationRecord.connection.execute(update_sql)
    end
    Delayed::Job.enqueue(ActivitiesCounterCacheJob.new, {:priority => -3, :run_at => 1.day.from_now})
  end

end
