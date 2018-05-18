module ProductsPlugin::ControlPanel
  class Products < ControlPanel::Entry
    class << self
      def name
        ('Products/Services')
      end

      def section
        'enterprise'
      end

      def icon
        'list-alt'
      end

      def priority
        10
      end

      def url(profile)
        {controller: 'products_plugin/page'}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end
    end
  end
end
