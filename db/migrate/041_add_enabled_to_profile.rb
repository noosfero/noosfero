class AddEnabledToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :enabled, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :enabled
  end
end
