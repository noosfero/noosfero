class AntiSpamPlugin < Noosfero::Plugin

  def self.plugin_name
    "AntiSpam"
  end

  def self.plugin_description
    _("Checks comments against a spam checking service compatible with the Akismet API")
  end

end
