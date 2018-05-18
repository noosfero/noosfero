module OrdersPlugin::ControlPanel
  class Orders < ControlPanel::Entry
    class << self

      def name
        I18n.t("orders_plugin.lib.plugin.person_panel_button")
      end

      def section
        'shopping'
      end

      def icon
        'list-ol'
      end

      def priority
        10
      end

      def url(profile)
        {:controller => :orders_plugin_admin, :action => :index}
      end

      def display?(user, profile, context={})
        profile.person?
      end
    end
  end
end
