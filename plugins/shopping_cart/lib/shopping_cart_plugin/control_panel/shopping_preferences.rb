module ShoppingCartPlugin::ControlPanel
  class ShoppingPreferences < ControlPanel::Entry
    class << self

      def name
        _('Preferences')
      end

      def section
        'shopping'
      end

      def icon
        'shopping-bag'
      end

      def priority
        0
      end

      def url(profile)
        {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end
    end
  end
end
