class OrdersCyclePlugin::Sale < OrdersPlugin::Sale

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_sales, source: :cycle
  has_one  :cycle,  through: :cycle_sale,  source: :cycle

  after_save :change_purchases, if: :cycle
  before_destroy :remove_purchases_items, if: :cycle

  def current_status
    return 'forgotten' if self.forgotten?
    super
  end

  def delivery?
    self.cycle.delivery?
  end
  def forgotten?
    self.draft? and !self.cycle.orders?
  end

  def open?
    super and self.cycle.orders?
  end

  def change_purchases
    return unless self.status_was.present?
    if self.ordered_at_was.nil? and self.ordered_at.present?
      self.add_purchases_items
    elsif self.ordered_at_was.present? and self.ordered_at.nil?
      self.remove_purchases_items
    end
  end

  def add_purchases_items
    ActiveRecord::Base.transaction do
      self.items.each do |item|
        next unless supplier_product = item.product.supplier_product
        next unless supplier = supplier_product.profile

        purchase = self.cycle.purchases.for_profile(supplier).first
        purchase ||= OrdersCyclePlugin::Purchase.create! cycle: self.cycle, consumer: self.profile, profile: supplier

        purchased_item = purchase.items.for_product(supplier_product).first
        purchased_item ||= purchase.items.build purchase: purchase, product: supplier_product
        purchased_item.quantity_consumer_ordered ||= 0
        purchased_item.quantity_consumer_ordered += item.status_quantity
        purchased_item.price_consumer_ordered ||= 0
        purchased_item.price_consumer_ordered += item.status_quantity * supplier_product.price
        purchased_item.save!
      end
    end
  end

  def remove_purchases_items
    ActiveRecord::Base.transaction do
      self.items.each do |item|
        next unless supplier_product = item.product.supplier_product
        next unless purchase = supplier_product.orders_cycles_purchases.for_cycle(self.cycle).first

        purchased_item = purchase.items.for_product(supplier_product).first
        purchased_item.quantity_consumer_ordered -= item.status_quantity
        purchased_item.price_consumer_ordered -= item.status_quantity * supplier_product.price
        purchased_item.save!

        purchased_item.destroy if purchased_item.quantity_consumer_ordered.zero?
        purchase.destroy if purchase.items(true).blank?
      end
    end
  end

  handle_asynchronously :add_purchases_items
  handle_asynchronously :remove_purchases_items

end
