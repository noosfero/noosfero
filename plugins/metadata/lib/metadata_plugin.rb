
class MetadataPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'metadata_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'metadata_plugin.lib.plugin.description'
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.og_types
    @og_types ||= self.config[:open_graph][:types] rescue {}
  end

  def head_ending
    plugin = self
    lambda do
      options = MetadataPlugin::Spec::Controllers[controller.controller_path.to_sym]
      options ||= MetadataPlugin::Spec::Controllers[:profile] if controller.is_a? ProfileController
      options ||= MetadataPlugin::Spec::Controllers[:environment]
      return unless options

      return unless object = case variable = options[:variable]
        when Proc then instance_exec(&variable) rescue nil
        else instance_variable_get variable
        end
      return unless metadata = (object.class.const_get(:Metadata) rescue nil)

      metadata.map do |property, contents|
        contents = contents.call(object, plugin) rescue nil if contents.is_a? Proc
        next if contents.blank?

        Array(contents).map do |content|
          content = content.call(object, plugin) rescue nil if content.is_a? Proc
          next if content.blank?
          tag 'meta', property: property, content: content
        end.join
      end.join
    end
  end

  # context HELPERS
  def og_url_for options
    options.delete :port
    options[:host] = self.class.config[:open_graph][:domain] rescue context.send(:environment).default_hostname
    Noosfero::Application.routes.url_helpers.url_for options
  end

  protected

end

ActiveSupport.run_load_hooks :metadata_plugin, MetadataPlugin

