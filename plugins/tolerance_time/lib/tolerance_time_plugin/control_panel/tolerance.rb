module ToleranceTimePlugin::ControlPanel
  class Tolerance <  ControlPanel::Entry
    class << self

      def name
       _('Tolerance Adjustements')
      end

      def section
        'content'
      end

      def icon
        'stopwatch'
      end

      # Url button points to.
      def url(profile)
        {:controller => 'tolerance_time_plugin_myprofile', :profile => profile.identifier}
      end
    end
  end
end
