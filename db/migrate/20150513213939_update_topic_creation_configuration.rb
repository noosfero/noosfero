class UpdateTopicCreationConfiguration < ActiveRecord::Migration
  def up
    Forum.where("setting LIKE '%:allows_members_to_create_topics: true%'").find_each do |forum|
      forum.setting.delete(:allows_members_to_create_topics)
      forum.setting.merge!(:topic_creation => 'related')
      forum.save
    end
  end

  def down
     say "this migration can't be reverted"
  end
end
