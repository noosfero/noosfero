class MailConf
  class << self

    def config_file
      File.join(RAILS_ROOT, 'config', 'mail.yml')
    end

    def config
      if File.exists?(config_file)
        YAML.load_file(config_file)
      else
        { 'webmail_url' =>  'http://webmail.example.com' }
      end
    end

    def enabled?
      config['enabled'] || false
    end

    def webmail_url(username, domain)
      config['webmail_url'] % [username, domain]
    end

  end
end
