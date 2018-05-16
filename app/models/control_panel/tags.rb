class ControlPanel::Tags < ControlPanel::Entry
  class << self
    def name
      _('Tags')
    end

    def section
      'interests'
    end

    def icon
      'tags'
    end

    def priority
      20
    end

    def url(profile)
     {:controller => 'profile_editor', :action => 'tags'}
    end
  end
end
