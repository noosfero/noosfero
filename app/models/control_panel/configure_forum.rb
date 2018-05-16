class ControlPanel::ConfigureForum < ControlPanel::Entry
  class << self
    def name
      _('Configure Forum')
    end

    def section
      'content'
    end

    def icon
      'comments'
    end

    def priority
      30
    end

    def custom_keywords
      [_('discussion'), _('debate')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'edit', :id => profile.forum}
    end

    def display?(user, profile, context={})
      profile.forums.count > 0
    end
  end
end
