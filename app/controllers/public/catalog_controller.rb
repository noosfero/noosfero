class CatalogController < ApplicationController
  needs_profile
  before_filter :check_enterprise_and_environment

  def index
    @products = @profile.products
  end

  def show
    @product = @profile.products.find(params[:id])
  end
  
  protected
  def check_enterprise_and_environment
    unless @profile.kind_of?(Enterprise) && !@profile.environment.enabled?('disable_products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
