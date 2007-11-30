class ProductCategoryViewerController < ApplicationController
  def index
    @categories = ProductCategory.find(:all)
  end

  def view_category
    @category = ProductCategory.find(params[:id])
    @products = Product.find(:all, :conditions => ['product_category_id = ?', params[:id]])
    @enterprises = Enterprise.find(:all, :conditions => ['products.id in (?)', @products.map(&:id)], :include => :products)
  end
end
