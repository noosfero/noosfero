class ProductCategory < Category
  has_many :products
  has_many :consumptions
  has_many :consumers, :through => :consumptions, :source => :profile_id

  def tree
    children.inject([]){|all,c| all + c.tree } << self
  end

  def all_products
    Product.find(:all, :conditions => { :product_category_id => tree.map(&:id) })
  end
end
