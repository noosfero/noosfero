class RefactorOrdersPluginModels < ActiveRecord::Migration
  def self.up
    remove_column :orders_plugin_orders, :total_collected
    remove_column :orders_plugin_orders, :total_payed

    add_column :orders_plugin_orders, :profile_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :consumer_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :supplier_delivery_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :consumer_delivery_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :payment_data, :text, :default => {}.to_yaml

    add_column :orders_plugin_orders, :data, :text, :default => {}.to_yaml

    rename_table :orders_plugin_products, :orders_plugin_items
    add_column :orders_plugin_items, :data, :text, :default => {}.to_yaml

    rename_column :orders_plugin_items, :quantity_allocated, :quantity_accepted
    rename_column :orders_plugin_items, :quantity_payed, :quantity_shipped
    rename_column :orders_plugin_items, :price_allocated, :price_accepted
    rename_column :orders_plugin_items, :price_payed, :price_shipped

    add_column :orders_plugin_items, :name, :string
    add_column :orders_plugin_items, :price, :decimal
  end

  def self.down
    say "this migration can't be reverted"
  end
end
