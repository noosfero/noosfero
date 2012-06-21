class AddDefaultToAcceptProductsFromCategory < ActiveRecord::Migration
  def self.up
    change_column_default :categories, :accept_products, true
  end

  def self.down
    change_column_default :categories, :accept_products, nil
  end
end
