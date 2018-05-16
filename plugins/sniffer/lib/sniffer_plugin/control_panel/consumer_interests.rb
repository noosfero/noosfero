module SnifferPlugin::ControlPanel
  class ConsumerInterests < ControlPanel::Entry
    class << self

      def name
        _('Consumer Interests')
      end

      def section
        'enterprise'
      end

      def icon
        'check-square'
      end

      def url(profile)
        {:controller => 'sniffer_plugin_myprofile', :action => 'edit'}
      end
    end
  end
end
