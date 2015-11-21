class SuppliersPluginMyprofileController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile

  before_filter :load_new, only: [:index, :new]

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def index
    @suppliers = search_scope(profile.suppliers.except_self).paginate(per_page: 30, page: params[:page])
    @is_search = params[:name] or params[:active]

    if request.xhr?
      render partial: 'suppliers_plugin_myprofile/suppliers_list', locals: {suppliers: @suppliers}
    end
  end

  def new
    @new_supplier.update! params[:supplier]
    @supplier = @new_supplier
    session[:notice] = t('controllers.myprofile.supplier_created')
  end

  def add
    @enterprise = environment.enterprises.find params[:id]
    @new_supplier = profile.suppliers.create! profile: @enterprise
  end

  def edit
    @supplier = profile.suppliers.find params[:id]
    @supplier.update params[:supplier]
  end

  def margin_change
    if params[:commit]
      profile.margin_percentage = params[:profile_data][:margin_percentage]
      profile.save
      profile.supplier_products_default_margins if params[:apply_to_all]

      render partial: 'suppliers_plugin/shared/pagereload'
    end
  end

  def toggle_active
    @supplier = profile.suppliers.find params[:id]
    @supplier.toggle! :active
  end

  def destroy
    @supplier = profile.suppliers.find params[:id]
    @supplier.destroy
  end

  def search
    @query = params[:query].downcase
    @enterprises = environment.enterprises.enabled.is_public.limit(12).order('name ASC').
      where('name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%")
    @enterprises -= profile.suppliers.collect(&:profile)
  end

  protected

  def load_new
    @new_supplier = SuppliersPlugin::Supplier.new_dummy consumer: profile
    @new_profile = @new_supplier.profile
  end

  def search_scope scope
    scope = scope.by_active params[:active] if params[:active].present?
    scope = scope.with_name params[:name] if params[:name].present?
    scope
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin

end
