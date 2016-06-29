require_dependency 'profile'

class Profile

  has_many :users_visits, -> { latest.with_users_page_views }, foreign_key: :profile_id, class_name: 'AnalyticsPlugin::Visit'

  has_many :visits, -> { latest.eager_load :page_views }, foreign_key: :profile_id, class_name: 'AnalyticsPlugin::Visit'
  has_many :page_views, foreign_key: :profile_id, class_name: 'AnalyticsPlugin::PageView'

  has_many :user_visits, -> { latest.eager_load :page_views }, foreign_key: :user_id, class_name: 'AnalyticsPlugin::PageView'
  has_many :user_page_views, foreign_key: :user_id, class_name: 'AnalyticsPlugin::PageView'

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
