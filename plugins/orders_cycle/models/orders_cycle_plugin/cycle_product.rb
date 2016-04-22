class OrdersCyclePlugin::CycleProduct < ApplicationRecord

  self.table_name = :orders_cycle_plugin_cycle_products

  belongs_to :cycle, :class_name => 'OrdersCyclePlugin::Cycle'
  belongs_to :product, :class_name => 'OrdersCyclePlugin::OfferedProduct', :dependent => :destroy # a product only belongs to one cycle

  validates_presence_of :cycle
  validates_presence_of :product

end
