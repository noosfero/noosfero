class Consumption < ActiveRecord::Base
  belongs_to :profile
  belongs_to :product_category
end
