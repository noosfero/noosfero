class Noosfero::Plugin

  # Plugins that are defined as modules should extend
  # this module manually, for example:
  #   module MyPlugin
  #     extend Noosfero::Plugin::ParentMethods
  #   end
  module ParentMethods

    def identifier
      @identifier ||= (if self.parents.first.instance_of? Module then self.parents.first else self end).name.underscore
    end

    def public_name
      @public_name ||= self.identifier.gsub '_plugin', ''
    end

    # Here the developer should specify the meta-informations that the plugin can
    # inform.
    def plugin_name
      self.identifier.humanize
    end
    def plugin_description
      _("No description informed.")
    end

    # Called for each ActiveRecord model with parents
    # See http://apidock.com/rails/ActiveRecord/ModelSchema/ClassMethods/full_table_name_prefix
    def table_name_prefix
      @table_name_prefix ||= "#{self.identifier}_"
    end

    def public_path file = '', relative=false
      File.join "#{if relative then '' else  '/' end}plugins", public_name, file
    end

    def root_path
      Rails.root.join('plugins', public_name)
    end

    def view_path
      File.join(root_path,'views')
    end

    def admin_url
      {:controller => "#{self.identifier}_admin", :action => 'index'}
    end

    def has_admin_url?
      File.exists?(File.join(root_path, 'controllers', "#{self.identifier}_admin_controller.rb"))
    end

    def controllers
      @controllers ||= Dir.glob("#{self.root_path}/controllers/*/*").map do |controller_file|
        next unless controller_file =~ /_controller.rb$/
        controller = File.basename(controller_file).gsub(/.rb$/, '').camelize
      end.compact
    end

  end

end
