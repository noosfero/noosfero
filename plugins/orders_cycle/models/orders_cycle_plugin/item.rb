class OrdersCyclePlugin::Item < OrdersPlugin::Item

  has_one :supplier, through: :product

  # see also: repeat_product
  attr_accessor :repeat_cycle

  delegate :cycle, to: :order

  # OVERRIDE OrdersPlugin::Item
  belongs_to :order, class_name: '::OrdersCyclePlugin::Order', foreign_key: :order_id, touch: true
  belongs_to :sale, class_name: '::OrdersCyclePlugin::Sale', foreign_key: :order_id, touch: true
  belongs_to :purchase, class_name: '::OrdersCyclePlugin::Purchase', foreign_key: :order_id, touch: true

  # WORKAROUND for direct relationship
  belongs_to :offered_product, foreign_key: :product_id, class_name: 'OrdersCyclePlugin::OfferedProduct'
  has_many :from_products, through: :offered_product
  has_one :from_product, through: :offered_product
  has_many :to_products, through: :offered_product
  has_one :to_product, through: :offered_product
  has_many :sources_supplier_products, through: :offered_product
  has_one :sources_supplier_product, through: :offered_product
  has_many :supplier_products, through: :offered_product
  has_one :supplier_product, through: :offered_product
  has_many :suppliers, through: :offered_product
  has_one :supplier, through: :offered_product

  # what items were selled from this item
  def selled_items
    self.order.cycle.selled_items.where(profile_id: self.consumer.id, orders_plugin_item: {product_id: self.product_id})
  end
  # what items were purchased from this item
  def purchased_items
    self.order.cycle.purchases.where(consumer_id: self.profile.id)
  end

  # override
  def repeat_product
    distributed_product = self.from_product
    return unless self.repeat_cycle and distributed_product
    self.repeat_cycle.products.where(from_products_products: {id: distributed_product.id}).first
  end

end
