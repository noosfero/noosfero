class Rpush270Updates < ActiveRecord::Migration[5.1]
  def self.up
    return if column_exists? :rpush_notifications, :notification

    change_column :rpush_notifications, :alert, :text
    add_column :rpush_notifications, :notification, :text
  end

  def self.down
    change_column :rpush_notifications, :alert, :string
    remove_column :rpush_notifications, :notification
  end
end
