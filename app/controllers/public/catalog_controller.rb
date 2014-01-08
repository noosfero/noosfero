class CatalogController < PublicController
  needs_profile
  no_design_blocks

  before_filter :check_enterprise_and_environment

  def index
    extend CatalogHelper
    catalog_load_index
  end

  protected

  def check_enterprise_and_environment
    unless profile.kind_of?(Enterprise) && @profile.environment.enabled?('products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
