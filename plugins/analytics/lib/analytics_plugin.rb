module AnalyticsPlugin

  TimeOnPageUpdateInterval = 2.minutes
  TimeOnPageUpdateIntervalMs = TimeOnPageUpdateInterval * 1000

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t'analytics_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t'analytics_plugin.lib.plugin.description'
  end

end
