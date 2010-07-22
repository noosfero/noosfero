class Input < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_category

  validates_presence_of :product
  validates_presence_of :product_category
end
