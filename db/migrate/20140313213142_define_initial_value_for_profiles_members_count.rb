class DefineInitialValueForProfilesMembersCount < ActiveRecord::Migration
   def self.up
    members_counts = execute("SELECT profiles.id, count(profiles.id) FROM profiles LEFT OUTER JOIN role_assignments ON profiles.id = role_assignments.resource_id WHERE (profiles.type = 'Organization' OR profiles.type = 'Community' OR profiles.type = 'Enterprise') GROUP BY profiles.id;")
    members_counts.each do |count|
      execute("UPDATE profiles SET members_count=#{count['count'].to_i} WHERE profiles.id=#{count['id']};")
    end
  end

  def self.down
      execute("UPDATE profiles SET members_count=0;")
  end
end
