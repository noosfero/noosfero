class CreateRegionValidatorsTable < ActiveRecord::Migration
  def self.up
    create_table :region_validators, :id => false do |t|
      t.column :region_id, :integer
      t.column :organization_id, :integer
    end
  end

  def self.down
    drop_table :region_validators
  end
end
