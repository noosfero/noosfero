class RemoveLockVersion < ActiveRecord::Migration
  def self.up
    remove_column :articles, :lock_version
  end

  def self.down
    add_column  :articles, :lock_version, :integer, :default => 0
  end
end
