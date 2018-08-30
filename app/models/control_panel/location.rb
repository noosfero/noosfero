class ControlPanel::Location < ControlPanel::Entry
  class << self
    def name
      _('Location')
    end

    def section
      'profile'
    end

    def icon
      'map-marker-alt'
    end

    def priority
      30
    end

    def custom_keywords
      [_('address'), _('position'), _('map')]
    end

    def url(profile)
      {:controller => 'profile_editor', :action => 'locality'}
    end

    def display?(user, profile, context={})
      (profile.active_fields & Profile::LOCATION_FIELDS).present? ||
        profile.active_fields.include?('location')
    end
  end
end
