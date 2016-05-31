class ProductsPlugin::QualifierCertifier < ApplicationRecord

  self.table_name = :qualifier_certifiers

  belongs_to :qualifier
  belongs_to :certifier

  validates_presence_of :qualifier

end
