class BscPlugin::Sale < ActiveRecord::Base

  validates_presence_of :product, :contract
  validates_uniqueness_of :product_id, :scope => :contract_id
  validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :price, :allow_nil => true

  belongs_to :product
  belongs_to :contract, :class_name => 'BscPlugin::Contract'

  before_create do |sale|
    sale.price ||= sale.product.price || 0
    sale.created_at ||= Time.now.utc
    sale.updated_at ||= Time.now.utc
  end

  before_update do |contract|
    contract.updated_at ||= Time.now.utc
  end

end
