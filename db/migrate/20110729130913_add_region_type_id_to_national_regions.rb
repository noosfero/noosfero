class AddRegionTypeIdToNationalRegions < ActiveRecord::Migration
  def self.up
    add_column :national_regions, :national_region_type_id, :integer
  end

  def self.down
    remove_column :national_regions, :national_region_type_id
  end
end
