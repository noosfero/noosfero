class RecentActivitiesPlugin < Noosfero::Plugin
  def self.plugin_name
    'RecentActivitiesPlugin'
  end

  def self.plugin_description
    _('Adds a block that lists recent profile activity.')
  end

  def self.extra_blocks
    {
      RecentActivitiesPlugin::ActivitiesBlock => { type: [Community, Person] }
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end
end

ApplicationHelper.include ActionTrackerHelper
