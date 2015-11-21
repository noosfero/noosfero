class OrdersCyclePluginItemController < OrdersPluginItemController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::DisplayHelper

  def new
    @offered_product = Product.find params[:offered_product_id]
    @consumer = user
    return render_not_found unless @offered_product
    raise 'Please login to place an order' if @consumer.blank?

    if params[:order_id] == 'new'
      @cycle = @offered_product.cycle
      raise 'Cycle closed for orders' unless @cycle.may_order? @consumer
      @order = OrdersCyclePlugin::Sale.create! cycle: @cycle, profile: profile, consumer: @consumer
    else
      @order = OrdersCyclePlugin::Sale.find params[:order_id]
      @cycle = @order.cycle
      raise 'Order confirmed or cycle is closed for orders' unless @order.open?
      raise 'You are not the owner of this order' unless @order.may_edit? @consumer, @admin
    end

    @item = OrdersCyclePlugin::Item.where(order_id: @order.id, product_id: @offered_product.id).first
    @item ||= OrdersCyclePlugin::Item.new
    @item.sale = @order
    @item.product = @offered_product
    if set_quantity_consumer_ordered(params[:quantity_consumer_ordered] || 1)
      @item.update! quantity_consumer_ordered: @quantity_consumer_ordered
    end
  end

  def edit
    return redirect_to url_for(params.merge action: :admin_edit) if @admin_edit
    super
    @offered_product = @item.product
    @cycle = @order.cycle
  end

  def admin_edit
    @item = OrdersCyclePlugin::Item.find params[:id]
    @order = @item.order
    @cycle = @order.cycle

    #update on association for total
    @order.items.each{ |i| i.attributes = params[:item] if i.id == @item.id }

    @item.update params[:item]
  end

  def destroy
    super
    @offered_product = @product
    @cycle = @order.cycle
  end

  protected

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

end
