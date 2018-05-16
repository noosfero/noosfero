class ControlPanel::ConfigureBlog < ControlPanel::Entry
  class << self
    def name
      _('Configure Blog')
    end

    def section
      'content'
    end

    def icon
      'file-alt'
    end

    def priority
      20
    end

    def custom_keywords
      [_('post')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'edit', :id => profile.blog}
    end

    def display?(user, profile, context={})
      profile.blogs.count > 0
    end
  end
end
