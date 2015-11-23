require_dependency 'product'

class Product

  has_many :items, class_name: 'OrdersPlugin::Item', foreign_key: :product_id, dependent: :destroy

  has_many :orders, through: :items
  has_many :sales, through: :items
  has_many :purchases, through: :items

  attr_accessor :quantity_ordered

  extend CurrencyHelper::ClassMethods
  instance_exec &OrdersPlugin::Item::DefineTotals

end
