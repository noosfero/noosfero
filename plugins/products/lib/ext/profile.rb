require_dependency 'profile'

class Profile

  has_many :products, foreign_key: :profile_id, dependent: :destroy, class_name: 'ProductsPlugin::Product'
  has_many :product_categories, through: :products, class_name: 'ProductsPlugin::ProductCategory'
  has_many :inputs, through: :products, class_name: 'ProductsPlugin::Input'
  has_many :production_costs, as: :owner, class_name: 'ProductsPlugin::ProductionCost'

end
