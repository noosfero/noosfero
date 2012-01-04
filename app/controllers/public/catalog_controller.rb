class CatalogController < PublicController
  needs_profile

  before_filter :check_enterprise_and_environment

  def index
    @products = @profile.products.paginate(:order => 'name asc', :per_page => 9, :page => params[:page])
  end

  protected

  def check_enterprise_and_environment
    unless @profile.kind_of?(Enterprise) && !@profile.environment.enabled?('disable_products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
