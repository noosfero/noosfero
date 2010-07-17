class CreateProductQualifiers < ActiveRecord::Migration
  def self.up
    create_table :product_qualifiers do |t|
      t.references :product
      t.references :qualifier
      t.references :certifier
      t.timestamps
    end
  end

  def self.down
    drop_table :product_qualifiers
  end
end
