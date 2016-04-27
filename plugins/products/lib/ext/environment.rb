require_dependency 'environment'

class Environment

  has_many :production_costs, class_name: 'ProductsPlugin::ProductionCost', as: :owner

  has_many :product_categories, class_name: 'ProductsPlugin::ProductCategory'

  has_many :products, through: :profiles

  has_many :qualifiers, class_name: 'ProductsPlugin::Qualifier'
  has_many :certifiers, class_name: 'ProductsPlugin::Certifier'

  has_many :units, -> { order 'position' }, class_name: 'ProductsPlugin::Unit'

  def highlighted_products_with_image(options = {})
    self.products.where(highlighted: true).joins(:image).order('created_at ASC')
  end

end
