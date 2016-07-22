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

  def self.clear_non_users
    ActiveRecord::Base.transaction do
      AnalyticsPlugin::PageView.bots.delete_all
      AnalyticsPlugin::PageView.not_page_loaded.delete_all
      # delete_all does not work here
      AnalyticsPlugin::Visit.without_page_views.destroy_all
    end
  end

end

Browser::Bot.detect_empty_ua!
