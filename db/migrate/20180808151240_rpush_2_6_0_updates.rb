class Rpush260Updates < ActiveRecord::Migration[5.1]
  def self.up
    return if column_exists? :rpush_notifications, :content_available
    add_column :rpush_notifications, :content_available, :boolean, default: false
  end

  def self.down
    remove_column :rpush_notifications, :content_available
  end
end

