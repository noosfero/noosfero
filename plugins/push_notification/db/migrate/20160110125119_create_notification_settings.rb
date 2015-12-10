class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :push_notification_plugin_notification_settings do |t|
      t.integer :user_id, null: false
      t.integer :notifications, null: false, :default => 0
      t.timestamps null: false
      t.index :user_id
    end
  end
end
