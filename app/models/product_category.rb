class ProductCategory < Category
  has_many :products
  has_many :consumptions
  has_many :consumers, :through => :consumptions, :source => :profile_id
end
