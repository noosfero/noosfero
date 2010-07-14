class ManageProductsController < ApplicationController
  needs_profile

  protect 'manage_products', :profile
  before_filter :check_environment_feature

  protected  
  def check_environment_feature
    if profile.environment.enabled?('disable_products_for_enterprises')
      render_not_found
      return
    end
  end

  public
  def index
    @products = @profile.products
    @consumptions = @profile.consumptions
  end

  def show
    @product = @profile.products.find(params[:id])
  end

  def categories_for_selection
    @category = Category.find(params[:category_id]) if params[:category_id]
    if @category
      @categories = @category.children
      @level = @category.leaf? ? @category.level : @categories.first.level
    else
      @categories = ProductCategory.top_level_for(environment)
      @level = 0
    end
    render :partial => 'categories_for_selection'
  end

  def new
    @product = @profile.products.build(params[:product])
    @category = @product.product_category
    @categories = ProductCategory.top_level_for(environment)
    @level = 0
    if request.post?
      if @product.save
        flash[:notice] = _('Product succesfully created')
        render :partial => 'shared/redirect_via_javascript',
          :locals => { :url => url_for(:controller => 'manage_products', :action => 'show', :id => @product) }
      else
        render :partial => 'shared/dialog_error_messages', :locals => { :object_name => 'product' }
      end
    end
  end

  def edit
    @object = @product = @profile.products.find(params[:id])
    @current_category = @product.product_category
    @categories = @current_category.nil? ? [] : @current_category.children
    if request.post?
      if @product.update_attributes(params[:product])
        flash[:notice] = _('Product succesfully updated')
        redirect_back_or_default :action => 'show', :id => @product
      else
        flash[:notice] = _('Could not update the product')
      end
    end
  end

  def destroy
    @product = @profile.products.find(params[:id])
    if @product.destroy
      flash[:notice] = _('Product succesfully removed')
      redirect_back_or_default :action => 'index'
    else
      flash[:notice] = _('Could not remove the product')
      redirect_back_or_default :action => 'show', :id => @product
    end
  end

end
