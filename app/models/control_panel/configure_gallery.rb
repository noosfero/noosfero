class ControlPanel::ConfigureGallery < ControlPanel::Entry
  class << self
    def name
      _('Configure Gallery')
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
      [_('photo'), _('image'), _('picture')]
    end

    def url(profile)
      {:controller => 'cms', :action => 'edit', :id => profile.gallery}
    end

    def display?(user, profile, context={})
      profile.galleries.count > 0
    end
  end
end

