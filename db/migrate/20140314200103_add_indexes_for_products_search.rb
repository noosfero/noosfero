class AddIndexesForProductsSearch < ActiveRecord::Migration
  def self.up
    add_index :products, :created_at
  end

  def self.down
    remove_index :products, :created_at
  end
end
