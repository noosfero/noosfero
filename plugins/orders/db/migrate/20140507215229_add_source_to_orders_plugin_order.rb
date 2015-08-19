class AddSourceToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_orders, :source, :string
    OrdersPlugin::Order.find_each do |order|
      next unless order.consumer_delivery_data.present? or order.payment_data.present?
      order.source = 'shopping_cart_plugin'
      order.save run_callbacks: false
    end
  end

  def self.down
  end
end
