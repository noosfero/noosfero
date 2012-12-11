require_dependency 'profile'

class Profile
  after_save_reindex [:articles], :with => :delayed_job
end
