class CreateActionTrackerNotifications < ActiveRecord::Migration
  def self.up
    create_table :action_tracker_notifications do |t|
      t.references :action_tracker
      t.references :profile
    end
  end

  def self.down
    drop_table :action_tracker_notifications
  end
end
