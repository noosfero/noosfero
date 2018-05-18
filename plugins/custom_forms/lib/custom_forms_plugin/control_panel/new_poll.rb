module CustomFormsPlugin::ControlPanel
  class NewPoll < ControlPanel::Entry
    class << self

      def name
        _('New Poll')
      end

      def section
        'custom_form_plugin_queries'
      end

      def icon
        'check-square'
      end

      def priority
        20
      end

      def url(profile)
        {profile: profile.identifier, controller: 'custom_forms_plugin_myprofile', action: 'new', kind: 'poll'}
      end
    end
  end
end
