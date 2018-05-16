class ControlPanel::Groups < ControlPanel::Entry
  class << self
    def name
      _('Groups')
    end

    def section
      'relationships'
    end

    def icon
      'sitemap'
    end

    def priority
      20
    end

    def custom_keywords
      [_('communities'), _('enterprises'), _('organizations')]
    end

    def url(profile)
      {:controller => 'memberships', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person?
    end
  end
end
