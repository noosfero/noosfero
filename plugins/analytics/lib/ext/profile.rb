require_dependency 'profile'
require_dependency 'community'

([Profile] + Profile.descendants).each do |subclass|
subclass.class_eval do

  has_many :visits, foreign_key: :profile_id, class_name: 'AnalyticsPlugin::Visit'
  has_many :page_views, foreign_key: :profile_id, class_name: 'AnalyticsPlugin::PageView'

end
end

class Profile

  def analytics_settings attrs = {}
    @analytics_settings ||= Noosfero::Plugin::Settings.new self, ::AnalyticsPlugin, attrs
    attrs.each{ |a, v| @analytics_settings.send "#{a}=", v }
    @analytics_settings
  end
  alias_method :analytics_settings=, :analytics_settings

  def analytics_enabled?
    self.analytics_settings.enabled
  end

  def analytics_anonymous?
    self.analytics_settings.anonymous
  end

end
