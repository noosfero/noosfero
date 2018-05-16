module AnalyticsPlugin::ControlPanel
  class AccessTracking < ControlPanel::Entry
    class << self
      def name
        I18n.t('analytics_plugin.lib.plugin.panel_button')
      end

      def section
        'profile'
      end

      def icon
        'chart-line'
      end

      def priority
        100
      end

      def url(profile)
        {controller: 'analytics_plugin/stats', profile: profile.identifier, action: :index}
      end

      def display?(user, profile, context={})
        user.is_admin? profile.environment
      end
    end
  end
end
