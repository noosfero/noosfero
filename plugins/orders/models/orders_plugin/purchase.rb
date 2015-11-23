class OrdersPlugin::Purchase < OrdersPlugin::Order

  def orders_name
    'purchases'
  end
  def actor_name
    :supplier
  end

  protected

end
