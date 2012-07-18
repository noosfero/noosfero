class AddNationalRegionCodeToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :national_region_code, :string, :null => true
  end

  def self.down
    remove_column :profiles, :national_region_code
  end
end
