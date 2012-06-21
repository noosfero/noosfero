class CreateNationalRegions < ActiveRecord::Migration
  def self.up
    create_table :national_regions do |t|
      t.string :name
      t.string :national_region_code
      t.string :parent_national_region_code

      t.timestamps
    end

    add_index(:national_regions, :national_region_code, {:name => "code_index"})
    add_index(:national_regions, :name, {:name => "name_index"})
  end

  def self.down
    drop_table :national_regions
  end
end
