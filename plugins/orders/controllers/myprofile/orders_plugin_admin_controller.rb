class OrdersPluginAdminController < MyProfileController

  include OrdersPlugin::Report
  include OrdersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::DisplayHelper

  def index
    @purchases_month = profile.purchases.latest.first.created_at.month rescue Date.today.month
    @purchases_year = profile.purchases.latest.first.created_at.year rescue Date.today.year
    @sales_month = profile.sales.latest.first.created_at.month rescue Date.today.month
    @sales_year = profile.sales.latest.first.created_at.year rescue Date.today.year

    @purchases = profile.purchases.latest.by_month(@purchases_month).by_year(@purchases_year).paginate(per_page: 30, page: params[:page])
    @sales = profile.sales.latest.by_month(@sales_month).by_year(@sales_year).paginate(per_page: 30, page: params[:page])
  end

  def filter
    @method = params[:orders_method]
    raise unless self.filter_methods.include? @method

    @actor_name = params[:actor_name].to_sym
    params[:page] = 1 if params[:page].blank?

    @scope ||= profile
    @scope = @scope.send @method
    @orders = hmvc_orders_context::Order.search_scope(@scope, params).paginate(per_page: 30, page: params[:page])

    respond_to do |format|
      format.html{ render partial: 'orders_plugin_admin/results', locals: { orders: @orders, actor_name: @actor_name} }
      format.js{ render template: 'orders_plugin_admin/filter' }
    end
  end

  def edit
    @actor_name = params[:actor_name].to_sym
    @orders_method = if @actor_name == :supplier then :sales else :purchases end

    @order = profile.send(@orders_method).find params[:id]
    return render_access_denied unless @order.verify_actor? profile, @actor_name
    @order.update_attributes params[:order]

    respond_to do |format|
      format.js{ render 'orders_plugin_admin/edit' }
      format.html{ render partial: 'orders_plugin_admin/edit', locals: {order: @order, actor_name: @actor_name} }
    end
  end

  def report_products
    @method = params[:orders_method]
    raise unless self.filter_methods.include? @method
    @scope ||= profile
    @scope = @scope.send @method
    @orders = @scope.where(id: params[:ids])
    report_file = report_products_by_supplier hmvc_orders_context::Order.supplier_products_by_suppliers @orders

    send_file report_file, type: 'application/xlsx',
      disposition: 'attachment',
      filename: t('controllers.myprofile.admin.products_report') % {
        date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier, name: ""}
  end

  def report_orders
    @method = params[:orders_method]
    raise unless self.filter_methods.include? @method
    @scope ||= profile
    @scope = @scope.send @method
    @orders = @scope.where(id: params[:ids])
    report_file = report_orders_by_consumer @orders

    send_file report_file, type: 'application/xlsx',
      disposition: 'attachment',
      filename: t('controllers.myprofile.admin.orders_report') % {date: DateTime.now.strftime("%Y-%m-%d"), profile_identifier: profile.identifier, name: ''}
  end

  protected

  def filter_methods
    ['sales', 'purchases']
  end

  def set_admin
    @admin = true
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
