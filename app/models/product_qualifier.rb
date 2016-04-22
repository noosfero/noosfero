class ProductQualifier < ApplicationRecord

  attr_accessible :qualifier, :product, :certifier

  belongs_to :qualifier
  belongs_to :product
  belongs_to :certifier
end
