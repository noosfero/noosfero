class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :enterprise_id
end
