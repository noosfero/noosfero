class ControlPanel::WelcomePage < ControlPanel::Entry
  class << self
    def name
      _('Welcome Page')
    end

    def section
      'design'
    end

    def icon
      'image'
    end

    def priority
      10
    end

    def url
     {:controller => 'profile_editor', :action => 'welcome_page'}
    end

    def display?(user, profile, context={})
      profile.is_template
    end
  end
end
