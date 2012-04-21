class PriceDetail < ActiveRecord::Base

  belongs_to :product
  validates_presence_of :product_id

  belongs_to :production_cost
  validates_presence_of :production_cost_id
  validates_uniqueness_of :production_cost_id, :scope => :product_id

  def price
    self[:price] || 0
  end

  include FloatHelper
  def price=(value)
    if value.is_a?(String)
      super(decimal_to_float(value))
    else
      super(value)
    end
  end

  def formatted_value(value)
    ("%.2f" % self[value]).to_s.gsub('.', product.enterprise.environment.currency_separator) if self[value]
  end

end
