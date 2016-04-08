class ShoppingCartPlugin::LineItem

  attr_accessor :product_id, :quantity

  def initialize(product_id, name)
    @product_id = product_id
    @name = name
    @quantity = 0
  end

  def product
    @product ||= Product.find_by id: product_id
  end

  def name
    product && product.name || @name
  end

  def ==(other)
    self.product == other.product && self.name == other.name && self.quantity == other.quantity
  end

end
