module SnifferPlugin::ControlPanel
  class OpportunitiesSniffer < ControlPanel::Entry
    class << self

      def name
        _('Opportunities Sniffer')
      end

      def section
        'enterprise'
      end

      def icon
        'bullhorn'
      end

      def url(profile)
        {:controller => 'sniffer_plugin_myprofile', :action => 'search'}
      end

      def display?(user, profile, context={})
        profile.enterprise?
      end

      def options
        { data: {'skip-pjax' => true} }
      end
    end
  end
end
