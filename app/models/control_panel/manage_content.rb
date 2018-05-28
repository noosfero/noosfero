class ControlPanel::ManageContent < ControlPanel::Entry
  class << self
    def name
      _('Manage')
    end

    def section
      'content'
    end

    def icon
      'folder'
    end

    def priority
      10
    end

    def custom_keywords
      [_('content'), _('cms')]
    end

    def url(profile)
      {controller: 'cms', action: 'index'}
    end
  end
end




