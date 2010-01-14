class AddVisibleToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :visible
  end
end
