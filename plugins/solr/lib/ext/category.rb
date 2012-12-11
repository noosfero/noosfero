require_dependency 'category'

class Category
  after_save_reindex [:articles, :profiles], :with => :delayed_job
end
