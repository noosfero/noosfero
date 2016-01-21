class AntiSpamPlugin < Noosfero::Plugin

  def self.plugin_name
    "AntiSpam"
  end

  def self.plugin_description
    _("Tests comments and suggested articles against a spam checking service compatible with the Akismet API")
  end

  def self.host_default_setting
    'rest.akismet.com'
  end

  def check_for_spam(object)
    if rakismet_call AntiSpamPlugin::Wrapper.wrap(object), object.environment, :spam?
      object.spam = true
      object.save!
    end
  end

  def marked_as_spam(object)
    rakismet_call AntiSpamPlugin::Wrapper.wrap(object), object.environment, :spam!
  end

  def marked_as_ham(object)
    rakismet_call AntiSpamPlugin::Wrapper.wrap(object), object.environment, :ham!
  end

  protected

  def rakismet_call(submission, environment, op)
    settings = Noosfero::Plugin::Settings.new(environment, self.class)

    Rakismet.host = settings.host
    Rakismet.key = settings.api_key
    Rakismet.url = environment.top_url

    submission.send(op)
  end

end
