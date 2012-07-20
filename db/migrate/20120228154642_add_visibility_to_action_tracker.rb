class AddVisibilityToActionTracker < ActiveRecord::Migration
  def self.up
    add_column :action_tracker, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :action_tracker, :visible, :boolean
  end
end
