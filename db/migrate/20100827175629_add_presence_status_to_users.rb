class AddPresenceStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_presence_status, :string, :default => ''
    add_column :users, :presence_status, :string, :default => ''
  end

  def self.down
    remove_column :users, :last_presence_status
    remove_column :users, :presence_status
  end
end
