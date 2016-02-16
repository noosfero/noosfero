require_dependency 'profile'
require_dependency 'community'

([Profile] + Profile.descendants).each do |subclass|
subclass.class_eval do

  has_many :orders_cycles, -> {
    order('created_at DESC').
    where "orders_cycle_plugin_cycles.status <> 'new'"
  }, foreign_key: :profile_id, class_name: 'OrdersCyclePlugin::Cycle', dependent: :destroy

  has_many :orders_cycles_without_order, -> {
    where "orders_cycle_plugin_cycles.status <> 'new'"
  }, foreign_key: :profile_id, class_name: 'OrdersCyclePlugin::Cycle'

  has_many :orders_cycles_sales, through: :orders_cycles, source: :sales
  has_many :orders_cycles_purchases, through: :orders_cycles, source: :purchases

  has_many :offered_products, -> { reorder 'products.name ASC' }, class_name: 'OrdersCyclePlugin::OfferedProduct'

end
end

class Profile

  def orders_cycles_closed_date_range
    list = self.orders_cycles.closing.order('start ASC').all
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
