require_dependency 'person'

class Person
  has_many :purchases, :class_name => "ShoppingCartPlugin::PurchaseOrder", :foreign_key => 'customer_id'
end
