class ControlPanel::Blocks < ControlPanel::Entry
  class << self
    def name
      _('Blocks')
    end

    def section
      'design'
    end

    def icon
      'th-large'
    end

    def priority
      50
    end

    def custom_keywords
      [_('sideblocks')]
    end

    def url(profile)
     {:controller => 'profile_design', :action => 'index'}
    end
  end
end


