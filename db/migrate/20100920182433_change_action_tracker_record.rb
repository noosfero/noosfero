class ChangeActionTrackerRecord < ActiveRecord::Migration
  def self.up
    rename_column(:action_tracker, :dispatcher_type, :target_type)
    rename_column(:action_tracker, :dispatcher_id, :target_id)
    ActionTracker:Record.where(verb: 'publish_article_in_community').update_all verb: 'create_article'
  end

  def self.down
    puts "Warning: cannot restore action tracker records with verb = 'publish_article_in_community'"
    rename_column(:action_tracker, :target_type, :dispatcher_type)
    rename_column(:action_tracker, :target_id, :dispatcher_id)
  end
end
