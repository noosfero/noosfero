class ControlPanel::EnterpriseValidation < ControlPanel::Entry
  class << self
    def name
      _('Validation')
    end

    def section
      'enterprise'
    end

    def icon
      'certificate'
    end

    def priority
      20
    end

    def custom_keywords
      [_('validate'), _('enterprise')]
    end

    def url(profile)
      {:controller => 'enterprise_validation', :action => 'index'}
    end

    def display?(user, profile, context={})
      !profile.environment.enabled?('disable_asset_enterprises') && profile.is_validation_entity?
    end
  end
end
