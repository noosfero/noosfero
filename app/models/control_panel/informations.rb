class ControlPanel::Informations < ControlPanel::Entry
  class << self
    def name
      _('Informations')
    end

    def section
      'profile'
    end

    def icon
      'id-card'
    end

    def priority
      0
    end

    def custom_keywords
      [_('personal')]
    end

    def url(profile)
      {:controller => 'profile_editor', :action => 'informations'}
    end
  end
end
