module CustomFormsPlugin::ControlPanel
  class NewSurvey < ControlPanel::Entry
    class << self

      def name
        _('New Survey')
      end

      def section
        'custom_form_plugin_queries'
      end

      def icon
        'list-alt'
      end

      def priority
        30
      end

      def url(profile)
        {profile: profile.identifier, controller: 'custom_forms_plugin_myprofile', action: 'new', kind: 'survey'}
      end
    end
  end
end
