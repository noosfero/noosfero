require_dependency 'price_detail'

class PriceDetail

  # should be on core, used by SuppliersPlugin::Import
  attr_accessible :production_cost

end
