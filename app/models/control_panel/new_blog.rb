class ControlPanel::NewBlog < ControlPanel::Entry
  class << self
    def name
      _('New Blog')
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
      [_('posts')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'new', :type => 'Blog'}
    end

    def display?(user, profile, context={})
      profile.blogs.count == 0
    end
  end
end
