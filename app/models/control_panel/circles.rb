class ControlPanel::Circles < ControlPanel::Entry
  class << self
    def name
      _('Circles')
    end

    def section
      'relationships'
    end

    def icon
      'user-circle'
    end

    def priority
      30
    end

    def custom_keywords
      [_('friends')]
    end

    def url(profile)
      {:controller => 'circles', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person?
    end
  end
end
