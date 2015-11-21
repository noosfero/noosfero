class SuppliersPlugin::ProductController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def index
    filter
    respond_to do |format|
      format.html{ render template: 'suppliers_plugin/product/index' }
      format.js{ render partial: 'suppliers_plugin/product/search' }
    end
  end

  def search
    filter
    if params[:page].present?
      render partial: 'suppliers_plugin/product/results'
    else
      render partial: 'suppliers_plugin/product/search'
    end
  end

  def add

  end

  def edit
    @product = profile.products.supplied.find params[:id]
    @product.update params["product_#{@product.id}"]
  end

  def import
    if params[:csv].present?
      if params[:remove_all_suppliers] == 'true'
        profile.suppliers.except_self.find_each(batch_size: 20){ |s| s.delay.destroy }
      end
      SuppliersPlugin::Import.delay.products profile, params[:csv].read

      @notice = t'controllers.product.import_in_progress'
      respond_to{ |format| format.js{ render layout: false } }
    else
      respond_to{ |format| format.html{ render layout: false } }
    end
  end

  def destroy
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.destroy
    flash[:notice] = t('controllers.myprofile.product_controller.product_removed_succe')
  end

  def distribute_to_consumers
    params[:consumers] ||= {}

    @product = profile.products.find params[:id]
    @consumers = profile.consumers.find(params[:consumers].keys.to_a).collect &:profile
    to_add = @consumers - @product.consumers
    to_remove = @product.consumers - @consumers

    to_add.each{ |c| @product.distribute_to_consumer c }

    to_remove = to_remove.to_set
    @product.to_products.each{ |p| p.destroy if to_remove.include? p.profile }

    @product.reload
  end

  protected

  def filter
    page = params[:page]
    page = 1 if page.blank?

    @supplier = SuppliersPlugin::Supplier.where(id: params[:supplier_id]).first if params[:supplier_id].present?

    # FIXME: joins(:from_products) is hiding own products (except baskets)
    @scope = profile.products.unarchived.joins :from_products, :suppliers
    @scope = SuppliersPlugin::BaseProduct.search_scope @scope, params
    @products_count = @scope.supplied_for_count.count
    @scope = @scope.supplied.select('products.*, MIN(from_products_products.name) as from_products_name').order('from_products_name ASC')
    @products = @scope.paginate per_page: 20, page: page

    @product_categories = Product.product_categories_of @products
    @new_product = SuppliersPlugin::DistributedProduct.new
    @new_product.profile = profile
    @new_product.supplier = @supplier
    @units = Unit.all
  end

  extend HMVC::ClassMethods
  hmvc SuppliersPlugin

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

end
