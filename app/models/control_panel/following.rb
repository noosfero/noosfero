class ControlPanel::Following < ControlPanel::Entry
  class << self
    def name
      _('Following')
    end

    def section
      'relationships'
    end

    def icon
      'chevron-circle-right'
    end

    def priority
      40
    end

    def custom_keywords
      [_('followers'), _('subscription')]
    end

    def url(profile)
      {:controller => 'followers', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person?
    end
  end
end
