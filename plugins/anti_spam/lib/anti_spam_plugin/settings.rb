class AntiSpamPlugin::Settings

  def initialize(environment, attributes = nil)
    @environment = environment
    attributes ||= {}
    attributes.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def settings
    @environment.settings[:anti_spam_plugin] ||= {}
  end

  def host
    settings[:host] ||= 'api.antispam.typepad.com'
  end

  def host=(value)
    settings[:host] = value
  end

  def api_key
    settings[:api_key]
  end

  def api_key=(value)
    settings[:api_key] = value
  end

  def save!
    @environment.save!
  end

end
