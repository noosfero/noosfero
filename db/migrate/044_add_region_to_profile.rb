class AddRegionToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :region_id, :integer
  end

  def self.down
    remove_column :profiles, :region_id
  end
end
