require_dependency 'product'

class Product
  after_save_reindex [:enterprise], :with => :delayed_job
end
