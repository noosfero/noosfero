require_dependency 'product'

class Product

  scope :in_cycle, -> { where type: 'OrdersCyclePlugin::OfferedProduct' }

end
