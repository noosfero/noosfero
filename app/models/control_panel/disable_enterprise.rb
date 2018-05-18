class ControlPanel::DisableEnterprise < ControlPanel::Entry
  class << self
    def name
      _('Disable')
    end

    def section
      'enterprise'
    end

    def icon
      'window-close'
    end

    def priority
      10
    end

    def custom_keywords
      [_('enterprise')]
    end

    def url(profile)
      {:controller => 'profile_editor', :action => 'disable'}
    end

    def display?(user, profile, context={})
      profile.enterprise? && profile.enabled?
    end
  end
end
