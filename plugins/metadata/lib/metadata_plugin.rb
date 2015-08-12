
module MetadataPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    _('Export metadata')
  end

  def self.plugin_description
    _('Export metadata for models on meta tags')
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.og_config
    @og_config ||= self.config[:open_graph] rescue {}
  end
  def self.og_types
    @og_types ||= self.og_config[:types] rescue {}
  end

  mattr_accessor :controllers
  self.controllers = MetadataPlugin::Controllers.new

end
