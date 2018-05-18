class ControlPanel::NewForum < ControlPanel::Entry
  class << self
    def name
      _('New Forum')
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
      [_('create'), _('discussion'), _('debate')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'new', :type => 'Forum'}
    end

    def display?(user, profile, context={})
      profile.forums.count == 0
    end
  end
end






