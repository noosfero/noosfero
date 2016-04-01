class ProductsPlugin::ProductQualifier < ApplicationRecord

  self.table_name = :product_qualifiers

  attr_accessible :qualifier, :product, :certifier

  belongs_to :qualifier
  belongs_to :product
  belongs_to :certifier

end
