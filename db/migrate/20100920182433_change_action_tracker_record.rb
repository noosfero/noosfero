class ChangeActionTrackerRecord < ActiveRecord::Migration
  def self.up
    rename_column(:action_tracker, :dispatcher_type, :target_type)
    rename_column(:action_tracker, :dispatcher_id, :target_id)
    ActionTracker::Record.update_all("verb='create_article'", {:verb => 'publish_article_in_community'})
  end

  def self.down
    raise "this migration can't be reverted"
    rename_column(:action_tracker, :target_type, :dispatcher_type)
    rename_column(:action_tracker, :target_id, :dispatcher_id)
  end
end
