class OrdersPluginController < PublicController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::DisplayHelper

  def repeat
    @orders = previous_orders.last(5).reverse
    @orders.each{ |o| o.enable_product_diff }
  end

  def clear_orders_session
    return if user
    previous_orders.update_all ['session_id = ?', nil]
  end

  protected

  def session_id
    session['session_id']
  end

  # reimplement on subclasses
  def supplier
  end

  def previous_orders
    if user
      supplier.orders.where consumer_id: user.id
    else
      supplier.orders.where session_id: session_id
    end
  end

end

