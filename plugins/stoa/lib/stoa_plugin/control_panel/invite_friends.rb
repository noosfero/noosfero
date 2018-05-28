module StoaPlugin::ControlPanel
  class InviteFriends < ControlPanel::Entry
    class << self

      def name
        c_('Invite friends')
      end

      def section
        'relationships'
      end

      def icon
        'envelope-open'
      end

      def priority
        15
      end

      def url(profile)
        {:controller => 'invite', :action => 'invite_friends'}
      end

      def display?(user, profile, context={})
        user == profile && user.usp_id.present?
      end
    end
  end
end
