class ControlPanel::EnableEnterprise < ControlPanel::Entry
  class << self
    def name
      _('Enable')
    end

    def section
      'enterprise'
    end

    def icon
      'check-square'
    end

    def priority
      10
    end

    def custom_keywords
      [_('enterprise')]
    end

    def url(profile)
      {:controller => 'profile_editor', :action => 'enable'}
    end

    def display?(user, profile, context={})
      profile.enterprise? && !profile.enabled?
    end
  end
end
