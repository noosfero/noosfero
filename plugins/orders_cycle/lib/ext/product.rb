require_dependency 'product'

# based on orders/lib/ext/product.rb
class Product

  has_many :orders_cycles_items, class_name: 'OrdersCyclePlugin::Item', foreign_key: :product_id

  has_many :orders_cycles_orders, through: :orders_cycles_items, source: :order
  has_many :orders_cycles_sales, through: :orders_cycles_items, source: :sale
  has_many :orders_cycles_purchases, through: :orders_cycles_items, source: :purchase

end
