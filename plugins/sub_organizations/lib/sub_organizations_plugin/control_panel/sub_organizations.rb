module SubOrganizationsPlugin::ControlPanel
  class SubOrganizations < ControlPanel::Entry
    class << self
      def name
        _('Subgroups')
      end

      def section
        'relationships'
      end

      def icon
        'sitemap'
      end

      def url(profile)
        {profile: profile.identifier, controller: :sub_organizations_plugin_myprofile}
      end

      def display?(user, profile, context={})
        profile.organization? && Organization.parentz(profile).blank?
      end
    end
  end
end
