class ManageProductsController < ApplicationController
  needs_profile

  def index
    @products = @profile.products
  end

  def show
    @product = @profile.products.find(params[:id])
  end

  def new
    @product = @profile.products.build(params[:product])
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
