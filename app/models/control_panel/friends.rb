class ControlPanel::Friends < ControlPanel::Entry
  class << self
    def name
      _('Friends')
    end

    def section
      'relationships'
    end

    def icon
      'users'
    end

    def priority
      10
    end

    def url(profile)
      {:controller => 'friends', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person?
    end
  end
end



