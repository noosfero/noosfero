class ControlPanel::Appearance < ControlPanel::Entry
  class << self
    def name
      _('Appearance')
    end

    def section
      'design'
    end

    def icon
      'paint-brush'
    end

    def priority
      30
    end

    def custom_keywords
      [_('layout'), _('boxes')]
    end

    def url(profile)
     {:controller => 'profile_themes', :action => 'index'}
    end

    def display?(user, profile, context={})
      return false if (!user || !profile)
      user.is_admin?(profile.environment) || profile.environment.enabled?('enable_appearance')
    end
  end
end

