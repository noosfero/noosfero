class DefineInitialValueForProfilesActivitiesCount < ActiveRecord::Migration
  def self.up
    person_activities_counts = execute("SELECT profiles.id, count(action_tracker.id) as count FROM profiles LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.user_id WHERE (action_tracker.created_at >= '#{30.days.ago.to_s(:db)}') AND ( (profiles.type = 'Person' ) ) GROUP BY profiles.id;")
    organization_activities_counts = execute("SELECT profiles.id, count(action_tracker.id) as count FROM profiles LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.target_id WHERE (action_tracker.created_at >= '#{30.days.ago.to_s(:db)}') AND ( (profiles.type = 'Community' OR profiles.type = 'Enterprise' OR profiles.type = 'Organization' ) ) GROUP BY profiles.id;")
    activities_counts = person_activities_counts.entries + organization_activities_counts.entries
    activities_counts.each do |count|
      execute("UPDATE profiles SET activities_count=#{count['count'].to_i} WHERE profiles.id=#{count['id']};")
    end
  end

  def self.down
    execute("UPDATE profiles SET activities_count=0;")
  end
end
