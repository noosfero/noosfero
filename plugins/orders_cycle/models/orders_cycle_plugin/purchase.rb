class OrdersCyclePlugin::Purchase < OrdersPlugin::Purchase

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_purchases, source: :cycle
  has_one  :cycle,  through: :cycle_purchase,  source: :cycle

end
