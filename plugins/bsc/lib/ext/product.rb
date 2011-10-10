require_dependency 'product'

class Product
  def bsc
    enterprise.bsc if enterprise
  end

  def display_supplier_on_search?
    false
  end
end
