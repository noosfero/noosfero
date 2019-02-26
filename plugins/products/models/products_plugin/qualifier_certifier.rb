class ProductsPlugin::QualifierCertifier < ApplicationRecord

  self.table_name = :qualifier_certifiers

  belongs_to :qualifier, optional: true
  belongs_to :certifier, optional: true

  validates_presence_of :qualifier

end
