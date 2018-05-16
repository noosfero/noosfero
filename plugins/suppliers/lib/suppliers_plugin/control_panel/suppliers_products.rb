module SuppliersPlugin::ControlPanel
  class SuppliersProducts < ControlPanel::Entry
    class << self

      def name
        I18n.t('suppliers_plugin.views.control_panel.products')
      end

      def section
        'enterprise'
      end

      def icon
        'list-ol'
      end

      def url(profile)
        {controller: 'suppliers_plugin/product', action: :index}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end
    end
  end
end
