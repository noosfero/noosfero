require_dependency 'action_tracker_model'

class ActionTracker::Record
  def label
    case self.target.class.name
    when 'Event'
      'events'
    when 'Community'
      'communities'
    when 'Friendship'
      'people'
    else
      'posts'
    end
  end
end
