require_dependency 'action_tracker_model'

class ActionTracker::Record

  after_create :fb_app_publish

  protected

  def fb_app_publish
    raise 'here'
  end
end
