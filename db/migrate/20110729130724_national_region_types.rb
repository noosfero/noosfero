class NationalRegionTypes < ActiveRecord::Migration
  def self.up
    create_table :national_region_types do |t|
      t.string :name
    end

    NationalRegionType.create  :name => "Country"
    NationalRegionType.create  :name => "State"
    NationalRegionType.create  :name => "City"

  end

  def self.down
    drop_table :national_region_types
  end
end
