class ProductCategory < Category
  # FIXME: do not allow category with products or inputs to be destroyed
  has_many :products
  has_many :inputs

  attr_accessible :name, :parent, :environment

  scope :unique, :select => 'DISTINCT ON (path) categories.*'
  scope :by_enterprise, -> enterprise {
    joins(:products).
    where('products.profile_id = ?', enterprise.id)
  }
  scope :by_environment, -> environment {
    where 'environment_id = ?', environment.id
  }
  scope :unique_by_level, -> level {
    select "DISTINCT ON (filtered_category) split_part(path, '/', #{level}) AS filtered_category, categories.*"
  }

  def all_products
    Product.where(product_category_id: (all_children << self).map(&:id))
  end

  def self.menu_categories(top_category, env)
    top_category ? top_category.children : top_level_for(env).select{|c|c.kind_of?(ProductCategory)}
  end

end
