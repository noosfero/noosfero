class ConsumedProductsController < ApplicationController
  needs_profile

  protect 'manage_products', :profile

  def index
    @consumptions = @profile.consumptions
    @product_categories = @profile.consumed_product_categories
  end

  def new
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

  def destroy
    @consumption = @profile.consumptions.find(params[:id])
    if @consumption.destroy
      flash[:notice] = _('Product succesfully removed')
    else
      flash[:notice] = _('Could not remove the product')
    end
    redirect_back_or_default :action => 'index'
  end

end
