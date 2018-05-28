class ControlPanel::Preferences < ControlPanel::Entry
  class << self
    def name
      _('Preferences')
    end

    def section
      'profile'
    end

    def icon
      'sliders-h'
    end

    def priority
      10
    end

    def custom_keywords
      [_('options'), _('settings')]
    end

    def url(profile)
      {:controller => 'profile_editor', :action => 'preferences'}
    end
  end
end
