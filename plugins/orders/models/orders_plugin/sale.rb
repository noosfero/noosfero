class OrdersPlugin::Sale < OrdersPlugin::Order

  before_validation :fill_default_supplier_delivery

  def orders_name
    'sales'
  end
  def actor_name
    :consumer
  end

  def purchase_quantity_total
    #TODO
    self.total_quantity_consumer_ordered
  end
  def purchase_price_total
    #TODO
    self.total_price_consumer_ordered
  end

  has_number_with_locale :purchase_quantity_total
  has_currency :purchase_price_total

  def supplier_delivery
    super || (self.delivery_methods.first rescue nil)
  end
  def supplier_delivery_id
    self[:supplier_delivery_id] || (self.supplier_delivery.id rescue nil)
  end

  def fill_default_supplier_delivery
    self[:supplier_delivery_id] ||= self.supplier_delivery.id if self.supplier_delivery
  end

  protected

end
