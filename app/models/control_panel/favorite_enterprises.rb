class ControlPanel::FavoriteEnterprises < ControlPanel::Entry
  class << self
    def name
      _('Favorite Enterprises')
    end

    def section
      'relationships'
    end

    def icon
      'briefcase'
    end

    def priority
      60
    end

    def url(profile)
      {:controller => 'favorite_enterprises', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person? && !profile.environment.enabled?('disable_asset_enterprises')
    end
  end
end
