module CustomFormsPlugin::ControlPanel
  class AllQueries < ControlPanel::Entry
    class << self

      def name
        _('View All')
      end

      def section
        'custom_form_plugin_queries'
      end

      def icon
        'book'
      end

      def priority
        10
      end

      def url(profile)
        {profile: profile.identifier, controller: 'custom_forms_plugin_myprofile'}
      end
    end
  end
end
