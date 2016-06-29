class RecentActivitiesPlugin::ActivitiesBlock < Block
  attr_accessible :limit
  settings_items :limit, type: :integer, default: 5

  def view_title
    self.default_title 
  end

  def activities
    list = self.limit.nil? ? owner.activities : owner.activities.limit(self.get_limit)
    list.map(&:activity)
  end

  def extra_option
    { }
  end

  def self.description
    _('Display the latest activities by the owner of the context where the block is available.')
  end

  def help
    _('This block lists your latest activities.')
  end

  def default_title
    _('Recent activities')
  end

  def api_content
    Api::Entities::Activity.represent(activities).as_json
  end

  def display_api_content_by_default?
    false
  end
end
