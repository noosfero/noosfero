
class MetadataPlugin::Base < Noosfero::Plugin

  def self.plugin_name
    _('Export metadata')
  end

  def self.plugin_description
    _('Export metadata for models on meta tags')
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.og_types
    @og_types ||= self.config[:open_graph][:types] rescue {}
  end

  class_attribute :controllers
  self.controllers = MetadataPlugin::Controllers.new

  def head_ending
    plugin = self
    lambda do
      variable = plugin.class.controllers.send controller.controller_path rescue nil
      variable ||= plugin.class.controllers.send :profile if controller.is_a? ProfileController
      variable ||= plugin.class.controllers.send :home
      return unless variable

      return unless object = case variable
        when Proc then instance_exec(&variable)
        else instance_variable_get variable
        end
      return if object.respond_to? :public? and not object.public?
      return unless specs = (object.class.metadata_specs rescue nil)

      r = []
      specs.each do |namespace, spec|
        namespace = "#{namespace}:" if namespace.present?
        key_attr = spec[:key_attr] || :property
        value_attr = spec[:value_attr] || :content
        tags = spec[:tags]

        tags.each do |key, values|
          key = "#{namespace}#{key}"
          values = values.call(object, plugin) if values.is_a? Proc rescue nil
          next if values.blank?

          Array(values).each do |value|
            value = value.call(object, plugin) if value.is_a? Proc rescue nil
            next if value.blank?
            value = h value unless value.html_safe?
            r << tag(:meta, {key_attr => key, value_attr => value.to_s}, false, false)
          end
        end
      end
      r.join
    end
  end

  include MetadataPlugin::UrlHelper

  def helpers
    self.context.class.helpers
  end

  protected

end

ActiveSupport.run_load_hooks :metadata_plugin, MetadataPlugin
ActiveSupport.on_load :active_record do
  ApplicationRecord.extend MetadataPlugin::Specs::ClassMethods
end

