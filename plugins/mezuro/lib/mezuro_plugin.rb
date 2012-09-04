require 'yaml'

Savon.configure do |config|
  config.log = HTTPI.log = (RAILS_ENV == 'development')
end

class MezuroPlugin < Noosfero::Plugin

  def self.plugin_name
    "Mezuro"
  end

  def self.plugin_description
    _("A metric analizer plugin.")
  end

  def content_types
    [MezuroPlugin::ConfigurationContent, MezuroPlugin::ProjectContent]
  end

  def stylesheet?
    true
  end

end
