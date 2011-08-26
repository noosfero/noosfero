class AddRegionTypeIdToNationalRegions < ActiveRecord::Migration
  def self.up
    add_column :national_regions, :national_region_type_id, :integer, :null => false
  end

  def self.down
    remove_column :national_regions, :national_region_type_id
  end
end
