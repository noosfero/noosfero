require_dependency 'enterprise'

class Enterprise
  has_many :orders, :class_name => "ShoppingCartPlugin::PurchaseOrder", :foreign_key => 'seller_id'
end
