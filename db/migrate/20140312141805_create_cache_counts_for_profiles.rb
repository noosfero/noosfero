class CreateCacheCountsForProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :friends_count, :integer, :null => false, :default => 0
    add_column :profiles, :members_count, :integer, :null => false,  :default => 0
    add_column :profiles, :activities_count, :integer, :null => false,  :default => 0
    add_index :profiles, :friends_count
    add_index :profiles, :members_count
    add_index :profiles, :activities_count
  end

  def self.down
    remove_column :profiles, :friends_count
    remove_column :profiles, :members_count
    remove_column :profiles, :activities_count
    remove_index :profiles, :friends_count
    remove_index :profiles, :members_count
    remove_index :profiles, :activities_count
  end
end
