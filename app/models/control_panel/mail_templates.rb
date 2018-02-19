class ControlPanel::MailTemplates < ControlPanel::Entry
  class << self
    def name
      _('Templates')
    end

    def section
      'mail'
    end

    def icon
      'envelope-open'
    end

    def priority
      20
    end

    def custom_keywords
      [_('email')]
    end

    def url(profile)
      {:controller => 'profile_email_templates', :action => 'index'}
    end

    def display?(user, profile, context={})
      profile.organization?
    end
  end
end
