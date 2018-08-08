class Rpush260Updates < ActiveRecord::Migration
  def self.up
    return if column_exists? :rpush_notifications, :content_available
    add_column :rpush_notifications, :content_available, :boolean, default: false
  end

  def self.down
    remove_column :rpush_notifications, :content_available
  end
end

