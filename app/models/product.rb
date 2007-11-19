class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :products_category

  validates_uniqueness_of :name, :scope => :enterprise_id
end
