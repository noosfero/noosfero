require_dependency 'product_category'

class ProductCategory

  has_many :sniffer_plugin_enterprises, -> { distinct },
    through: :products, source: :enterprise

end
