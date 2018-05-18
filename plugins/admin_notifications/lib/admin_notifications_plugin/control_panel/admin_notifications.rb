module AdminNotificationsPlugin::ControlPanel
  class AdminNotifications < ControlPanel::Entry
    class << self

      def name
        _('Admin Notifications')
      end

      def section
        'profile'
      end

      def icon
        'bell'
      end

      def url(profile)
        {:controller => 'admin_notifications_plugin_myprofile', :action => 'index'}
      end

      def display?(user, profile, context={})
        profile.organization?
      end
    end
  end
end
