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

  def action_tracker_user
    return self.enterprise if self.enterprise.validated

    if self.enterprise.bsc
       self.enterprise.bsc
    else
       self.enterprise
    end
  end
end
