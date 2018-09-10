class Rpush210Updates < ActiveRecord::Migration
  def self.up
    return if column_exists? :rpush_notifications, :url_args
    add_column :rpush_notifications, :url_args, :text, null: true
    add_column :rpush_notifications, :category, :string, null: true
  end

  def self.down
    remove_column :rpush_notifications, :url_args
    remove_column :rpush_notifications, :category
  end
end
