class ControlPanel::Privacy < ControlPanel::Entry
  class << self
    def name
      _('Privacy')
    end

    def section
      'security'
    end

    def icon
      'user-secret'
    end

    def priority
      10
    end

    def url(profile)
     {:controller => 'profile_editor', :action => 'privacy'}
    end
  end
end


