
class MetadataPlugin < Noosfero::Plugin

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

  CONTROLLERS = {
    manage_products: {
      variable: :@product,
    },
    content_viewer: {
      variable: proc do
        if profile and profile.home_page_id == @page.id
          @profile
        elsif @page.respond_to? :encapsulated_file
          @page.encapsulated_file
        else
          @page
        end
      end,
    },
    profile: {
      variable: :@profile,
    },
    # fallback
    environment: {
      variable: :@environment,
    },
  }

  def head_ending
    plugin = self
    lambda do
      options = MetadataPlugin::CONTROLLERS[controller.controller_path.to_sym]
      options ||= MetadataPlugin::CONTROLLERS[:profile] if controller.is_a? ProfileController
      options ||= MetadataPlugin::CONTROLLERS[:environment]
      return unless options

      return unless object = case variable = options[:variable]
        when Proc then instance_exec(&variable) rescue nil
        else instance_variable_get variable
        end
      return unless specs = (object.class.metadata_specs rescue nil)

      r = []
      specs.each do |namespace, spec|
        namespace = "#{namespace}:" if namespace.present?
        key_attr = spec[:key_attr] || :property
        value_attr = spec[:value_attr] || :content
        tags = spec[:tags]

        tags.each do |key, values|
          key = "#{namespace}#{key}"
          values = values.call(object, plugin) rescue nil if values.is_a? Proc
          next if values.blank?

          Array(values).each do |value|
            value = value.call(object, plugin) rescue nil if value.is_a? Proc
            next if value.blank?
            r << tag(:meta, key_attr => key, value_attr => value)
          end
        end
      end
      r.join
    end
  end

  # context HELPERS
  def og_url_for options
    options.delete :port
    options[:host] = self.class.config[:open_graph][:domain] rescue context.send(:environment).default_hostname
    Noosfero::Application.routes.url_helpers.url_for options
  end

  def helpers
    self.context.class.helpers
  end

  protected

end

ActiveSupport.run_load_hooks :metadata_plugin, MetadataPlugin
ActiveSupport.on_load :active_record do
  ActiveRecord::Base.extend MetadataPlugin::Specs::ClassMethods
end

