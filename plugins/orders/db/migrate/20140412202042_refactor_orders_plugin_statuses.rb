class RefactorOrdersPluginStatuses < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_items, :draft, :boolean

    add_column :orders_plugin_items, :quantity_consumer_ordered, :decimal
    add_column :orders_plugin_items, :quantity_supplier_accepted, :decimal
    add_column :orders_plugin_items, :quantity_supplier_separated, :decimal
    add_column :orders_plugin_items, :quantity_supplier_delivered, :decimal
    add_column :orders_plugin_items, :quantity_consumer_received, :decimal
    add_column :orders_plugin_items, :price_consumer_ordered, :decimal
    add_column :orders_plugin_items, :price_supplier_accepted, :decimal
    add_column :orders_plugin_items, :price_supplier_separated, :decimal
    add_column :orders_plugin_items, :price_supplier_delivered, :decimal
    add_column :orders_plugin_items, :price_consumer_received, :decimal

    add_column :orders_plugin_items, :unit_id_consumer_ordered, :integer
    add_column :orders_plugin_items, :unit_id_supplier_accepted, :integer
    add_column :orders_plugin_items, :unit_id_supplier_separated, :integer
    add_column :orders_plugin_items, :unit_id_supplier_delivered, :integer
    add_column :orders_plugin_items, :unit_id_consumer_received, :integer

    OrdersPlugin::Item.reset_column_information
    OrdersPlugin::Item.record_timestamps = false
    OrdersPlugin::Item.find_each do |order|
      order.quantity_consumer_ordered = order.quantity_asked
      order.quantity_supplier_accepted = order.quantity_accepted
      order.quantity_supplier_delivered = order.quantity_shipped
      order.price_consumer_ordered = order.price_asked
      order.price_supplier_accepted = order.price_accepted
      order.price_supplier_delivered = order.price_shipped
      order.save run_callbacks: false
    end

    add_column :orders_plugin_orders, :ordered_at, :datetime
    add_column :orders_plugin_orders, :accepted_at, :datetime
    add_column :orders_plugin_orders, :separated_at, :datetime
    add_column :orders_plugin_orders, :delivered_at, :datetime
    add_column :orders_plugin_orders, :received_at, :datetime

    OrdersPlugin::Order.record_timestamps = false
    OrdersPlugin::Order.where(status: 'confirmed').update_all status: 'ordered'
    OrdersPlugin::Order.find_each do |order|
      order.ordered_at = order.updated_at if order.status == 'ordered'
      order.save run_callbacks: false
    end

    remove_column :orders_plugin_items, :quantity_asked
    remove_column :orders_plugin_items, :quantity_accepted
    remove_column :orders_plugin_items, :quantity_shipped
    remove_column :orders_plugin_items, :price_asked
    remove_column :orders_plugin_items, :price_accepted
    remove_column :orders_plugin_items, :price_shipped

  end

  def self.down
    say "this migration can't be reverted"
  end
end
