module FbAppPlugin::ControlPanel
  class FbApp <  ControlPanel::Entry
    class << self

      def name
        FbAppPlugin.plugin_name
      end

      def section
        'profile'
      end

      def icon
        'facebook'
      end

      def custom_keywords
        ['facebook']
      end

      def url(profile)
        {host: FbAppPlugin.config[:app][:domain], profile: profile.identifier, controller: :fb_app_plugin_myprofile}
      end

      def display?(user, profile, context={})
        FbAppPlugin.config.present?
      end
    end
  end
end
