module MailingListPlugin::ControlPanel
  class PersonList < ControlPanel::Entry
    class << self

      def name
        _('Mailing Lists')
      end

      def section
        'profile'
      end

      def icon
        'envelope-square'
      end

      def url(profile)
        {:controller => 'mailing_list_plugin_myprofile_person', :action => 'edit'}
      end

      def display?(user, profile, context={})
        profile.person?
      end
    end
  end
end

