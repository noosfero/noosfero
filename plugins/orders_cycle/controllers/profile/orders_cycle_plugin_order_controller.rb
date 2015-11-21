class OrdersCyclePluginOrderController < OrdersPluginOrderController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  no_design_blocks
  before_filter :login_required, except: [:index]

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::DisplayHelper

  def index
    @current_year = DateTime.now.year.to_s
    @year = (params[:year] || @current_year).to_s

    @years_with_cycles = profile.orders_cycles_without_order.years.collect &:year
    @years_with_cycles.unshift @current_year unless @years_with_cycles.include? @current_year

    @cycles = profile.orders_cycles.by_year @year
    @consumer = user
  end

  def new
    if user.blank?
      session[:notice] = t('orders_plugin.controllers.profile.consumer.please_login_first')
      redirect_to action: :index
      return
    end

    if not profile.members.include? user
      render_access_denied
    else
      @consumer = user
      @cycle = profile.orders_cycles.find params[:cycle_id]
      @order = OrdersCyclePlugin::Sale.new
      @order.profile = profile
      @order.consumer = @consumer
      @order.cycle = @cycle
      @order.save!
      redirect_to url_for(params.merge action: :edit, id: @order.id)
    end
  end

  def repeat
    @consumer = user
    @order = profile.orders_cycles_sales.where(id: params[:order_id], consumer_id: @consumer.id).first
    @cycle = profile.orders_cycles.find params[:cycle_id]
    if @order
      @order.repeat_cycle = @cycle
      @repeat_order = OrdersCyclePlugin::Sale.new profile: profile, consumer: @consumer, cycle: @cycle
      @order.items.each do |item|
        next unless item.repeat_product and item.repeat_product.available
        @repeat_order.items.build sale: @repeat_order, product: item.repeat_product, quantity_consumer_ordered: item.quantity_consumer_ordered
      end
      @repeat_order.supplier_delivery = @order.supplier_delivery
      @repeat_order.save!
      redirect_to url_for(params.merge action: :edit, id: @repeat_order.id)
    else
      @orders = @cycle.consumer_previous_orders(@consumer).last(5).reverse
      @orders.each{ |o| o.enable_product_diff }
      @orders.each{ |o| o.repeat_cycle = @cycle }
      render template: 'orders_plugin/repeat'
    end
  end

  def edit
    return show_more if params[:page].present?

    if request.xhr? and params[:order].present?
      status = params[:order][:status]
      if status == 'ordered'
        if @order.items.size > 0
          @order.to_yaml # most strange workaround to avoid a crash in the next line
          @order.update! params[:order]
          session[:notice] = t('orders_plugin.controllers.profile.consumer.order_confirmed')
        else
          session[:notice] = t('orders_plugin.controllers.profile.consumer.can_not_confirm_your_')
        end
      end
      return
    end

    if cycle_id = params[:cycle_id]
      @cycle = profile.orders_cycles.where(id: cycle_id).first
      return render_not_found unless @cycle
      @consumer = user

      # load the first order
      unless @order
        @consumer_orders = @cycle.sales.for_consumer @consumer
        if @consumer_orders.size == 1
          @order = @consumer_orders.first
          redirect_to action: :edit, id: @order.id
        elsif @consumer_orders.size > 1
          # get the first open
          @order = @consumer_orders.find{ |o| o.open? }
          redirect_to action: :edit, id: @order.id if @order
        end
      end
    else
      return render_not_found unless @order
      # an order was loaded on load_order

      @cycle = @order.cycle

      @consumer = @order.consumer
      @admin_edit = (user and user.in?(profile.admins) and user != @consumer)
      return render_access_denied unless @user_is_admin or @admin_edit or user == @consumer

      @consumer_orders = @cycle.sales.for_consumer @consumer
    end

    load_products_for_order
    @product_categories = @cycle.product_categories
    @consumer_orders = @cycle.sales.for_consumer @consumer
  end

  def reopen
    @order.update! status: 'draft'
    render 'edit'
  end

  def cancel
    @order.update! status: 'cancelled'
    session[:notice] = t('orders_plugin.controllers.profile.consumer.order_cancelled')
    render 'edit'
  end

  def remove
    super
    redirect_to action: :index, cycle_id: @order.cycle.id
  end

  def admin_new
    return redirect_to action: :index unless profile.has_admin? user

    @consumer = user
    @cycle = profile.orders_cycles.find params[:cycle_id]
    @order = OrdersCyclePlugin::Sale.create! cycle: @cycle, consumer: @consumer
    redirect_to action: :edit, id: @order.id, profile: profile.identifier
  end

  def filter
    if id = params[:id]
      @order = OrdersCyclePlugin::Sale.find id rescue nil
      @cycle = @order.cycle
    else
      @cycle = profile.orders_cycles.find params[:cycle_id]
      @order = OrdersCyclePlugin::Sale.find params[:order_id] rescue nil
    end
    load_products_for_order

    render partial: 'filter', locals: {
      order: @order, cycle: @cycle,
      products_for_order: @products,
    }
  end

  def show_more
    filter
  end

  def supplier_balloon
    @supplier = profile.suppliers.find params[:id]
  end
  def product_balloon
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
  end

  protected

  def load_products_for_order
    scope = @cycle.products_for_order
    page, per_page = params[:page].to_i, 20
    page = 1 if page < 1
    @products = OrdersCyclePlugin::OfferedProduct.search_scope(scope, params).paginate page: page, per_page: per_page
  end

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

end
