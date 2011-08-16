class AddShoppingCartDeliveryToProfile < ActiveRecord::Migration

  def self.up
    add_column :profiles, :shopping_cart_delivery, :boolean, :default => false
    add_column :profiles, :shopping_cart_delivery_price, :decimal, :default => 0
  end

  def self.down
    remove_column :profiles, :shopping_cart_delivery
    remove_column :profiles, :shopping_cart_delivery_price
  end
end
