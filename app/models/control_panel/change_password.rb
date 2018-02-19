class ControlPanel::ChangePassword < ControlPanel::Entry
  class << self
    def name
      _('Change Password')
    end

    def section
      'security'
    end

    def icon
      'lock'
    end

    def priority
      20
    end

    def url(profile)
     {:controller => 'account', :action => 'change_password'}
    end
  end
end



