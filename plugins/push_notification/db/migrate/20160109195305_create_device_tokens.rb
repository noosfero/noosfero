class CreateDeviceTokens < ActiveRecord::Migration
  def change
    create_table :push_notification_plugin_device_tokens do |t|
      t.integer :user_id, null: false
      t.string :device_name, null:false
      t.string :token, null: false, unique: true
      t.timestamps null: false
      t.index :user_id
    end
  end
end
