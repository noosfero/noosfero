class ControlPanel::Roles < ControlPanel::Entry
  class << self
    def name
      _('Roles')
    end

    def section
      'relationships'
    end

    def icon
      'id-badge'
    end

    def priority
      30
    end

    def url(profile)
      {:controller => 'profile_roles', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.organization?
    end
  end
end

