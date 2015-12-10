class CreateNotificationSubscriptions < ActiveRecord::Migration
  def change
    create_table :push_notification_plugin_notification_subscriptions do |t|
      t.string :notification, :unique => true
      t.integer :environment_id, null: false
      t.text :subscribers
    end
  end
end
