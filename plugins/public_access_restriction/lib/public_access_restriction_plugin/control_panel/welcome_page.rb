module PublicAccessRestrictionPlugin::ControlPanel
  class WelcomePage < ControlPanel::Entry
    class << self

      def name
        _('Public Welcome Page')
      end

      def section
        'profile'
      end

      def icon
        'file-image'
      end

      def url(profile)
        {controller: 'public_access_restriction_plugin_page', action: 'index'}
      end

      def display?(user, profile, context={})
        profile.organization?
      end
    end
  end
end
