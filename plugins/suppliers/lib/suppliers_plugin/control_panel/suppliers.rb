module SuppliersPlugin::ControlPanel
  class Suppliers< ControlPanel::Entry
    class << self

      def name
        I18n.t('suppliers_plugin.views.control_panel.suppliers')
      end

      def section
        'enterprise'
      end

      def icon
        'truck'
      end

      def url(profile)
        {controller: :suppliers_plugin_myprofile, action: :index}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end
    end
  end
end
