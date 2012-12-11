require_dependency 'enterprise'

class Enterprise
  after_save_reindex [:products], :with => :delayed_job
end
