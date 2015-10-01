require_dependency 'profile'

class Profile

  has_many :orders_cycles, class_name: 'OrdersCyclePlugin::Cycle', dependent: :destroy, order: 'created_at DESC',
    conditions: ["orders_cycle_plugin_cycles.status <> 'new'"]
  has_many :orders_cycles_without_order, class_name: 'OrdersCyclePlugin::Cycle',
    conditions: ["orders_cycle_plugin_cycles.status <> 'new'"]

  has_many :orders_cycles_sales, through: :orders_cycles, source: :sales
  has_many :orders_cycles_purchases, through: :orders_cycles, source: :purchases

  has_many :offered_products, class_name: 'OrdersCyclePlugin::OfferedProduct', order: 'products.name ASC'

  def orders_cycles_closed_date_range
    list = self.orders_cycles.closing.all order: 'start ASC'
    return DateTime.now..DateTime.now if list.blank?
    list.first.start.to_date..list.last.finish.to_date
  end

  def orders_cycles_products_default_margins
    self.class.transaction do
      self.orders_cycles.opened.each do |cycle|
        cycle.products.each do |product|
          product.margin_percentage = margin_percentage
          product.save!
        end
      end
    end
  end

end
