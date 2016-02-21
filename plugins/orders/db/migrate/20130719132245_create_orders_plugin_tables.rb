class CreateOrdersPluginTables < ActiveRecord::Migration
  def self.up
    # check if distribution plugin already moved tables
    return if ApplicationRecord.connection.table_exists? :orders_plugin_orders

    create_table :orders_plugin_orders do |t|
      t.integer  :profile_id
      t.integer  :consumer_id
      t.integer  :supplier_delivery_id
      t.integer  :consumer_delivery_id
      t.decimal  :total_collected
      t.decimal  :total_payed
      t.string   :status
      t.integer  :code
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :orders_plugin_orders, [:consumer_delivery_id]
    add_index :orders_plugin_orders, [:consumer_id]
    add_index :orders_plugin_orders, [:profile_id]
    add_index :orders_plugin_orders, [:status]
    add_index :orders_plugin_orders, [:supplier_delivery_id]

    create_table :orders_plugin_products do |t|
      t.integer  :product_id
      t.integer  :order_id
      t.decimal  :quantity_asked,     :default => 0.0
      t.decimal  :quantity_allocated, :default => 0.0
      t.decimal  :quantity_payed,     :default => 0.0
      t.decimal  :price_asked,        :default => 0.0
      t.decimal  :price_allocated,    :default => 0.0
      t.decimal  :price_payed,        :default => 0.0
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :orders_plugin_products, [:order_id]
    add_index :orders_plugin_products, [:product_id]

  end

  def self.down
    drop_table :orders_plugin_orders
    drop_table :orders_plugin_products
  end
end
