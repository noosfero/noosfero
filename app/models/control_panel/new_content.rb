class ControlPanel::NewContent < ControlPanel::Entry
  class << self
    def name
      _('New')
    end

    def section
      'content'
    end

    def icon
      'plus'
    end

    def priority
      0
    end

    def custom_keywords
      [_('content'), _('create')]
    end

    def url(profile)
      {controller: 'cms', action: 'new', cms: true}
    end

    def options
      {class: 'open-modal'}
    end
  end
end



