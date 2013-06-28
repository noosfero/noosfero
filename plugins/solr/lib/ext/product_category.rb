require_dependency 'product_category'

class ProductCategory
  after_save_reindex [:products], :with => :delayed_job
end

