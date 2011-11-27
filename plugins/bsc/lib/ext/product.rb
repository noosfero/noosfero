require_dependency 'product'

class Product

  has_many :sales, :class_name => 'BscPlugin::Sale'
  has_many :contracts, :through => :sales, :class_name => 'BscPlugin::Contract'

  def bsc
    enterprise.bsc if enterprise
  end

  def display_supplier_on_search?
    false
  end
end
