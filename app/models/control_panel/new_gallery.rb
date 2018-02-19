class ControlPanel::NewGallery < ControlPanel::Entry
  class << self
    def name
      _('New Gallery')
    end

    def section
      'content'
    end

    def icon
      'camera'
    end

    def priority
      40
    end

    def custom_keywords
      [_('create'), _('photos'), _('images')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'new', :type => 'Gallery'}
    end

    def display?(user, profile, context={})
      profile.galleries.count == 0
    end
  end
end
