class ControlPanel::Members < ControlPanel::Entry
  class << self
    def name
      _('Members')
    end

    def section
      'relationships'
    end

    def icon
      'users'
    end

    def priority
      10
    end

    def url(profile)
      {:controller => 'profile_members', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.organization? && user.has_permission?(:manage_memberships, profile)
    end
  end
end




