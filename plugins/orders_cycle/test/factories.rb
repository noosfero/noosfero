module OrdersCyclePlugin::Factory

  def defaults_for_suppliers_plugin_supplier
    {:profile => build(Profile),
     :consumer => build(Profile)}
  end

  def defaults_for_suppliers_plugin_distributed_product attrs = {}
    profile = attrs[:profile] || build(Profile)
    {:profile => profile, :name => "product-#{factory_num_seq}", :price => 2.0,
     :product => build(Product, :enterprise => profile.profile, :price => 2.0),
     :supplier => build(SuppliersPlugin::Supplier, :profile => profile, :consumer => profile)}
  end

  def defaults_for_orders_cycle_plugin_offered_product attrs = {}
    hash = defaults_for_orders_cycle_plugin_product(attrs)
    profile = hash[:profile]
    hash.merge({
      :from_products => [build(SuppliersPlugin::DistributedProduct, :profile => profile)]})
  end

  def defaults_for_delivery_plugin_method
    {:profile => build(OrdersCyclePlugin::Profile),
     :name => "My delivery #{factory_num_seq.to_s}",
     :delivery_type => 'deliver'}
  end

  def defaults_for_delivery_plugin_option
    {:cycle => build(OrdersCyclePlugin::Cycle),
     :delivery_method => build(DeliveryPlugin::Method)}
  end

  def defaults_for_orders_plugin_order attrs = {}
    profile = attrs[:profile] || build(OrdersCyclePlugin::Profile)
    {:status => 'ordered',
     :cycle => build(OrdersCyclePlugin::Cycle, :profile => profile),
     :consumer => build(OrdersCyclePlugin::Profile),
     :supplier_delivery => build(DeliveryPlugin::Method, :profile => profile),
     :consumer_delivery => build(DeliveryPlugin::Method, :profile => profile)}
  end

  def defaults_for_orders_plugin_items
    {:order => build(OrdersPlugin::Order),
     :product => build(OrdersCyclePlugin::OfferedProduct),
     :quantity_shipped => 1.0, :quantity_ordered => 2.0, :quantity_accepted => 3.0,
     :price_shipped => 10.0, :price_ordered => 20.0, :price_accepted => 30.0}
  end

  def defaults_for_orders_cycle_plugin_cycle
    {:profile => build(OrdersCyclePlugin::Profile), :status => 'orders',
     :name => 'weekly', :start => Time.now, :finish => Time.now+1.days}
  end

end

Noosfero::Factory.register_extension OrdersCyclePlugin::Factory

