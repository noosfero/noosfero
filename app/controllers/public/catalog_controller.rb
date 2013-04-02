class CatalogController < PublicController
  needs_profile
  no_design_blocks

  before_filter :check_enterprise_and_environment

  def index
    @category = params[:level] ? ProductCategory.find(params[:level]) : nil
    @products = @profile.products.from_category(@category).paginate(:order => 'available desc, highlighted desc, name asc', :per_page => 9, :page => params[:page])
    @categories = ProductCategory.on_level(params[:level]).order(:name)
  end

  protected

  def check_enterprise_and_environment
    unless @profile.kind_of?(Enterprise) && !@profile.environment.enabled?('disable_products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
