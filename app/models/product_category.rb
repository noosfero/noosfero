class ProductCategory < Category
  has_many :products
  has_many :inputs

  def all_products
    Product.find(:all, :conditions => { :product_category_id => (all_children << self).map(&:id) })
  end

  def self.menu_categories(top_category, env)
    top_category ? top_category.children : top_level_for(env).select{|c|c.kind_of?(ProductCategory)}
  end
end
