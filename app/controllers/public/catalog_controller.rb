class CatalogController < ApplicationController
  needs_profile
  before_filter :check_enterprise

  def index
    @products = @profile.products
  end

  def show
    @product = @profile.products.find(params[:id])
  end
  
  protected
  def check_enterprise
    @profile.kind_of? Enterprise
  end

end
