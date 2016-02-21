OrdersPlugin.send :remove_const, :Item if defined? OrdersPlugin::Item
OrdersPlugin.send :remove_const, :Order if defined? OrdersPlugin::Order

class ShoppingCartPlugin::PurchaseOrder < ApplicationRecord
  acts_as_having_settings field: :data

  module Status
    OPENED = 0
    CANCELED = 1
    CONFIRMED = 2
    SHIPPED = 3
  end
end

class Profile
  has_many :orders, class_name: 'OrdersPlugin::Order'
end

class OrdersPlugin::Item < ApplicationRecord
  belongs_to :order, class_name: 'OrdersPlugin::Order'
end
class OrdersPlugin::Order < ApplicationRecord
  has_many :items, class_name: 'OrdersPlugin::Item', foreign_key: :order_id

  extend CodeNumbering::ClassMethods
  code_numbering :code, scope: proc{ self.profile.orders }
end

StatusTransform = {
  ShoppingCartPlugin::PurchaseOrder::Status::OPENED => 'ordered',
  ShoppingCartPlugin::PurchaseOrder::Status::CONFIRMED => 'accepted',
  ShoppingCartPlugin::PurchaseOrder::Status::CANCELED => 'cancelled',
  ShoppingCartPlugin::PurchaseOrder::Status::SHIPPED => 'delivered',
}

class MoveShoppingCartPurchaseOrderToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    OrdersPlugin::Order.record_timestamps = false

    ShoppingCartPlugin::PurchaseOrder.order('created_at ASC').find_each do |purchase_order|
      data = purchase_order.data

      order = OrdersPlugin::Order.new profile_id: purchase_order.seller_id, consumer_id: purchase_order.customer_id

      order.consumer_data = {}
      ['contact_phone','name','email'].each do |prop|
        order.consumer_data[prop.to_sym] = data[('customer_'+prop).to_sym]
      end

      order.consumer_delivery_data = {
        :name           => data[:customer_delivery_option],
        :address_line1  => data[:customer_address],
        :address_line2  => data[:customer_district],
        :postal_code    => data[:customer_zip_code],
        :state          => data[:customer_state],
        :country        => 'Brasil'
      }
      order.supplier_delivery_data = {}

      data[:products_list].each do |id, data|
        item = order.items.build product_id: id, name: data[:name], quantity_consumer_ordered: data[:quantity], price: data[:price]
        item.order = order
      end

      order.payment_data = {
        :method         => data[:customer_payment],
        :change         => data[:customer_change]
      }

      order.status = StatusTransform[purchase_order.status]

      order.updated_at = purchase_order.updated_at
      order.created_at = purchase_order.created_at

      order.save!
    end

    # Leave table for registry
    #drop_table :shopping_cart_plugin_purchase_orders

    OrdersPlugin::Order.record_timestamps = true
  end

  def self.down
  end
end
