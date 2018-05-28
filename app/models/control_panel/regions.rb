class ControlPanel::Regions < ControlPanel::Entry
  class << self
    def name
      _('Regions')
    end

    def section
      'interests'
    end

    def icon
      'map'
    end

    def priority
      30
    end

    def url(profile)
     {:controller => 'profile_editor', :action => 'regions'}
    end
  end
end

