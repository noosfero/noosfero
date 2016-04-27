require_dependency 'products_plugin/product_category'

module ProductsPlugin
  class ProductCategory

    has_many :sniffer_plugin_enterprises, -> { distinct }, through: :products, source: :profile

  end
end
