class RecentActivitiesPlugin::ActivitiesBlock < Block
  attr_accessible :limit
  settings_items :limit, type: :integer, default: 5

  def view_title
    self.default_title 
  end

  def activities
    activities = owner.activities.where(activity_type: ActionTracker::Record.to_s)
    list = self.limit.nil? ? activities : activities.limit(self.get_limit)
    list.map(&:activity)
  end

  def extra_option
    { }
  end

  def self.description
    _('Display the latest activities by the owner of the context where the block is available.')
  end

  def help
    _('This block lists your latest activities. By default, any user that goes to your profile will be able to see all activities. Configure the "Display to users" option if you don\'t want that.')
  end

  def default_title
    _('Recent activities')
  end

  def api_content(options = {})
    Api::Entities::Activity.represent(activities).as_json
  end

  def display_api_content_by_default?
    false
  end

  def timeout
    4.hours
  end

  def self.expire_on
    { profile: [:article] }
  end
end
