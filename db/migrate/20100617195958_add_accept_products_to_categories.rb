class AddAcceptProductsToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :accept_products, :boolean, :default => true
    execute 'UPDATE categories SET accept_products = (1 > 0)'
  end

  def self.down
    remove_column :categories, :accept_products
  end
end
