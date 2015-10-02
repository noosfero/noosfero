class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  attr_accessible :from_products

  # missed from lib/ext/product.rb because of STI
  attr_accessible :external_id, :price_details

  validates_presence_of :supplier

  def supplier_price
    self.supplier_product.price if self.supplier_product
  end

  # Automatic set/get price chaging/applying margins
  # FIXME: this won't work if we have other params, like fixed margin, delivery cost, etc
  def price
    base_price = self.supplier_price
    return super if base_price.blank?

    self.price_with_margins base_price
  end
  def price= value
    return super if value.blank?
    value = value.to_f
    base_price = self.supplier_price
    return super if base_price.blank?

    self.margin_percentage = 100 * (value - base_price) / base_price
    super
  end

  protected

end
