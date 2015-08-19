class OrdersPluginItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  #protect 'edit_profile', :profile
  before_filter :set_actor_name

  helper OrdersPlugin::DisplayHelper

  def edit
    @consumer = user
    @item = hmvc_orders_context::Item.find params[:id]
    @product = @item.product
    @order = @item.send self.order_method

    unless @order.may_edit? @consumer
      raise 'Order confirmed or cycle is closed for orders' unless @order.open?
      raise 'Please login to place an order' if @consumer.blank?
      raise 'You are not the owner of this order' if @consumer != @order.consumer
    end

    if params[:item].present? and set_quantity_consumer_ordered params[:item][:quantity_consumer_ordered]
      params[:item][:quantity_consumer_ordered] = @quantity_consumer_ordered
      @item.update_attributes! params[:item]
    end
  end

  def destroy
    @item = hmvc_orders_context::Item.find params[:id]
    @product = @item.product
    @order = @item.send self.order_method

    @item.destroy
  end

  protected

  def set_quantity_consumer_ordered value
    @quantity_consumer_ordered = CurrencyHelper.parse_localized_number value

    if @quantity_consumer_ordered > 0
      min = @item.product.minimum_selleable rescue nil
      if min and @quantity_consumer_ordered < min
        @quantity_consumer_ordered = min
        @quantity_consumer_ordered_less_than_minimum = @item.id || true
      end
    elsif @item
      @quantity_consumer_ordered = nil
      destroy
      render action: :destroy
    end

    @quantity_consumer_ordered
  end

  def order_method
    'sale'
  end

  # default value, may be overwriten
  def set_actor_name
    @actor_name = :consumer
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
