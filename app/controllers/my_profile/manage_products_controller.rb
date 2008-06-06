class ManageProductsController < ApplicationController
  needs_profile

  protect 'manage_products', :profile

  def index
    @products = @profile.products
    @consumptions = @profile.consumptions
  end

  def show
    @product = @profile.products.find(params[:id])
  end

  def new
    @current_category = ProductCategory.top_level_for(environment).first
    @categories = @current_category.nil? ? [] : @current_category.children
    @product = @profile.products.build(params[:product])
    @product.build_image unless @product.image
    if request.post?
      if @product.save
        flash[:notice] = _('Product succesfully created')
        redirect_to :action => 'show', :id => @product
      else
        flash[:notice] = _('Could not create the product')
      end
    end
  end

  def edit
    @product = @profile.products.find(params[:id])
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

  def update_subcategories
    @current_category = ProductCategory.find(params[:id])
    @categories = @current_category.children
    render :partial => 'subcategories'
  end
  
  def new_consumption
    @consumption = @profile.consumptions.build(params[:consumption])
    if request.post?
      if @consumption.save
        flash[:notice] = _('Product succesfully created')
        redirect_to :action => 'index'
      else
        flash[:notice] = _('Could not create the product')
      end
    end
  end

  def destroy_consumption
    @consumption = @profile.consumptions.find(params[:id])
    if @consumption.destroy
      flash[:notice] = _('Product succesfully removed')
    else
      flash[:notice] = _('Could not remove the product')
    end
    redirect_back_or_default :action => 'index'
  end
 
  def edit_consumption
    @consumption = @profile.consumptions.find(params[:id])
    if request.post?
      if @consumption.update_attributes(params[:consumption])
        flash[:notice] = _('Consumed product succesfully updated')
        redirect_back_or_default :action => 'index'
      else
        flash[:notice] = _('Could not update the consumed product')
      end
    end
  end

end
