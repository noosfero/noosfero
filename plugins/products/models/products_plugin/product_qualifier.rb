class ProductsPlugin::ProductQualifier < ApplicationRecord

  self.table_name = :product_qualifiers

  attr_accessible :qualifier, :product, :certifier

  belongs_to :qualifier, optional: true, dependent: :destroy
  belongs_to :product, optional: true, dependent: :destroy
  belongs_to :certifier, optional: true, dependent: :destroy

end
