class ControlPanel::Spam < ControlPanel::Entry
  class << self
    def name
      _('Spam')
    end

    def section
      'profile'
    end

    def icon
      'bug'
    end

    def priority
      70
    end

    def url(profile)
      {:controller => 'spam', :action => 'index'}
    end
  end
end
