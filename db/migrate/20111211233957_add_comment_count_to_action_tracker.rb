class AddCommentCountToActionTracker < ActiveRecord::Migration
  def self.up
    add_column :action_tracker, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :action_tracker, :comments_count, :integer
  end
end
