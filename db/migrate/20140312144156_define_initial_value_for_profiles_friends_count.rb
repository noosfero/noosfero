class DefineInitialValueForProfilesFriendsCount < ActiveRecord::Migration
  def self.up
    friends_counts = execute("SELECT profiles.id, count(profiles.id) FROM profiles INNER JOIN friendships ON ( profiles.id = friendships.friend_id AND profiles.type = E'Person') GROUP BY profiles.id;")
    friends_counts.each do |count|
      execute("UPDATE profiles SET friends_count=#{count['count'].to_i} WHERE profiles.id=#{count['id']};")
    end
  end

  def self.down
      execute("UPDATE profiles SET friends_count=0;")
  end
end
