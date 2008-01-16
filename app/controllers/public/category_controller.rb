class CategoryController < ApplicationController

  before_filter :load_default_enviroment

  #FIXME This is not necessary because the application controller define the envrioment 
  # as the default holder
 
  def boxes_holder
    environment
  end

  def load_default_enviroment
    @environment = Environment.default
  end

  before_filter :load_category, :only => [ :view ]
  def load_category
    path = params[:path].join('/')
    @category = environment.categories.find_by_path(path)
    if @category.nil?
      render_not_found(path)
    end
  end

  # view the summary of one category
  def view
    send(@category.class.name.underscore.to_sym)
    # TODO: load articles, documents, etc so the view can list them.
  end

  protected
  def product_category
    @products = @category.all_products
    @enterprises = Enterprise.find(:all, :conditions => ['products.id in (?)', @products.map(&:id)], :include => :products)
    @users = Profile.find(:all, :conditions => ['consumptions.product_category_id = (?)',@category.id], :include => :consumptions)
  end

  def category
  end

  def region
  end

end
