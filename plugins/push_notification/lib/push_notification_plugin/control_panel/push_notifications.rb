module PushNotificationPlugin::ControlPanel
  class PushNotifications < ControlPanel::Entry
    class << self

      def name
        I18n.t("push_notification_plugin.lib.plugin.panel_button")
      end

      def section
        'profile'
      end

      def icon
        'bell'
      end

      def priority
        15
      end

      def url(profile)
        {controller: 'push_notification_plugin_myprofile', action: 'index'}
      end

      def display?(user, profile, context={})
        profile.person?
      end
    end
  end
end
