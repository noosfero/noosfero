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
    unless @profile.kind_of? Enterprise
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
