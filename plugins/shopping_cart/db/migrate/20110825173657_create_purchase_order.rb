class CreatePurchaseOrder < ActiveRecord::Migration
  def self.up
    create_table :shopping_cart_plugin_purchase_orders do |t|
      t.references :customer
      t.references :seller
      t.text :data
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :shopping_cart_plugin_purchase_order
  end
end
