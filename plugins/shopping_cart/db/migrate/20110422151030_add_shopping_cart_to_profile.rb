class AddShoppingCartToProfile < ActiveRecord::Migration

  def self.up
    add_column :profiles, :shopping_cart, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :shopping_cart
  end
end
