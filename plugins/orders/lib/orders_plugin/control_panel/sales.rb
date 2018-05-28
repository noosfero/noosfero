module OrdersPlugin::ControlPanel
  class Sales < ControlPanel::Entry
    class << self

      def name
        I18n.t("orders_plugin.lib.plugin.panel_button")
      end

      def section
        'shopping'
      end

      def icon
        'money-bill-alt'
      end

      def priority
        10
      end

      def url(profile)
        {:controller => :orders_plugin_admin, :action => :index}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end
    end
  end
end
