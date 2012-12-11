require_dependency 'qualifier'

class Qualifier
  after_save_reindex [:products], :with => :delayed_job
end

