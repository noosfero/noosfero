class ControlPanel::Tasks < ControlPanel::Entry
  class << self
    def name
      _('Tasks')
    end

    def section
      'profile'
    end

    def icon
      'tasks'
    end

    def priority
      20
    end

    def custom_keywords
      [_('actions'), _('moderate'), _('review')]
    end

    def url(profile)
      {:controller => 'tasks', :action => 'index'}
    end
  end
end
