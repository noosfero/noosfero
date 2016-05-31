if defined? OrdersPlugin
  require_dependency "orders_plugin/item"

  class OrdersPlugin::Item

    delegate :supplier, to: :product

  end
end
