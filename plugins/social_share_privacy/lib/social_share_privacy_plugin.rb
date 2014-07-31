class SocialSharePrivacyPlugin < Noosfero::Plugin

  def self.plugin_name
    "Social Share Privacy"
  end

  def self.plugin_description
    _("A plugin that adds share buttons from other networks.")
  end

  def self.networks_default_setting
    []
  end

  def stylesheet?
    true
  end

end
