class ControlPanel::Categories < ControlPanel::Entry
  class << self
    def name
      _('Categories')
    end

    def section
      'interests'
    end

    def icon
      'certificate'
    end

    def priority
      10
    end

    def url(profile)
     {:controller => 'profile_editor', :action => 'categories'}
    end
  end
end
