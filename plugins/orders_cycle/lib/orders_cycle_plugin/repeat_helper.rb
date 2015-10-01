module OrdersCyclePlugin::RepeatHelper

  def repeat_checkout_order_button order
    button :check, t('views.public.repeat.checkout'), {controller: :orders_cycle_plugin_order, action: :repeat, order_id: order.id, cycle_id: @cycle.id},
      class: 'repeat-checkout-order'
  end

  def repeat_choose_order_button order
    nil
  end

end

