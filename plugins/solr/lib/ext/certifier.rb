require_dependency 'certifier'

class Certifier
  after_save_reindex [:products], :with => :delayed_job
end

