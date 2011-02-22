class MailConf
  class << self

    def default_webmail_url
      'http://webmail.example.com'
    end

    def enabled?
      NOOSFERO_CONF['mail_enabled'] || false
    end

    def webmail_url(username, domain)
      (NOOSFERO_CONF['webmail_url'] || default_webmail_url) % [username, domain]
    end

  end
end
