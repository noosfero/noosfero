class SuppliersPlugin::BasketController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile
  before_filter :set_allowed_user

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def search
    @product = profile.products.supplied.find params[:id]
    @query = params[:query].to_s
    @scope = profile.products.supplied.limit(10)
    @scope = @scope.where('id NOT IN (?)', @product.id)
    # not a good option as need to search on from_products to, solr is a perfect match
    #@products = @scope.where('name ILIKE ? OR name ILIKE ?', "#{@query}%", "% #{@query}%")
    @products = autocomplete(:catalog, @scope, @query, {per_page: 10, page: 1}, {})[:results]

    render json: @products.map{ |p|
      {value: p.id, label: "#{p.name} (#{if p.respond_to? :supplier then p.supplier.name else p.profile.short_name end})"}
    }
  end

  def add
    @product = profile.products.supplied.find params[:id]
    @aggregate = profile.products.supplied.find params[:aggregate_id]

    @sp = @product.sources_from_products.where(from_product_id: @aggregate.id).first
    if @sp
      @sp.update_column :quantity, @sp.quantity + 1
    else
      @sp = @product.sources_from_products.create! from_product: @aggregate, to_product: @product
    end

    render partial: 'suppliers_plugin/manage_products/basket_tab'
  end

  def remove
    @product = profile.products.supplied.find params[:id]
    @aggregate = profile.products.supplied.find params[:aggregate_id]
    @sp = @product.sources_from_products.where(from_product_id: @aggregate.id).first
    @sp.destroy

    render partial: 'suppliers_plugin/manage_products/basket_tab'
  end

  protected

  extend HMVC::ClassMethods
  hmvc SuppliersPlugin

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

  def set_allowed_user
    @allowed_user = true
  end

end
