require_dependency 'product_category'

class ProductCategory
  has_many :sniffer_plugin_enterprises, :through => :products, :source => :enterprise, :uniq => true
end
