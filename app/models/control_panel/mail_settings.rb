class ControlPanel::MailSettings < ControlPanel::Entry
  class << self
    def name
      _('Settings')
    end

    def section
      'mail'
    end

    def icon
      'envelope'
    end

    def priority
      10
    end

    def custom_keywords
      [_('email')]
    end

    def url(profile)
      {:controller => 'mailconf', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.person? && MailConf.enabled?
    end
  end
end
