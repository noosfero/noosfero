class CreatePriceDetails < ActiveRecord::Migration
  def self.up
    create_table :price_details do |t|
      t.decimal :price, :default => 0
      t.references :product
      t.references :production_cost
      t.timestamps
    end
  end

  def self.down
    drop_table :price_details
  end
end
