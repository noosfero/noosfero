module MailingListPlugin::ControlPanel
  class OrganizationList < ControlPanel::Entry
    class << self

      def name
        _('Mailing List')
      end

      def section
        'profile'
      end

      def icon
        'envelope-square'
      end

      def url(profile)
        {:controller => 'mailing_list_plugin_myprofile_organization', :action => 'edit'}
      end

      def display?(user, profile, context={})
        profile.organization?
      end
    end
  end
end
