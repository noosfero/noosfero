class OrdersPluginAdminItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersPlugin::DisplayHelper

  def edit
    @consumer = user
    @item = OrdersPlugin::Item.find params[:id]
    @actor_name = params[:actor_name].to_sym
    @order = if @actor_name == :consumer then @item.purchase else @item.sale end

    @item.update_attributes! params[:item]
  end

  def add_search
    @order = hmvc_orders_context::Order.find params[:order_id]
    @query = params[:query].to_s
    @scope = @order.available_products.limit(10)
    @scope = @scope.includes :suppliers if defined? SuppliersPlugin
    # FIXME: do not work cycles
    #@products = autocomplete(:catalog, @scope, @query, {per_page: 10, page: 1}, {})[:results]
    @products = @scope.where('name ILIKE ? OR name ILIKE ?', "#{@query}%", "% #{@query}%")

    render json: @products.map{ |p|
      {value: p.id, label: "#{p.name} (#{if p.respond_to? :supplier then p.supplier.name else p.profile.short_name end})"}
    }
  end

  def add
    @actor_name = params[:actor_name].to_sym
    @order = hmvc_orders_context::Order.find params[:order_id]
    @product = @order.available_products.find params[:product_id]

    @item = hmvc_orders_context::Item.where(order_id: @order.id, product_id: @product.id).first
    @item ||= hmvc_orders_context::Item.new order: @order, product: @product
    @item.next_status_quantity_set @actor_name, (@item.next_status_quantity(@actor_name) || @item.status_quantity || 0) + 1
    @item.save!
  end

  protected

  def set_admin
    @admin = true
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
