require 'noosfero'
include ActionView::Helpers::AssetTagHelper

class Noosfero::Plugin

  attr_accessor :context

  class << self

    def init_system
      Dir.glob(File.join(Rails.root, 'config', 'plugins', '*')).select do |entry|
        File.directory?(entry)
      end.each do |dir|
        Rails.configuration.controller_paths << File.join(dir, 'controllers')
        Dependencies.load_paths << File.join(dir, 'controllers')
        [ Dependencies.load_paths, $:].each do |path|
          path << File.join(dir, 'models')
          path << File.join(dir, 'lib')
        end

        plugin_name = File.basename(dir).camelize + 'Plugin'
        plugin_name.constantize # load the plugin
      end
    end

    def all
      @all ||= []
    end

    def inherited(subclass)
      all << subclass.to_s unless all.include?(subclass.to_s)
    end

    def public_name
      self.name.underscore.gsub('_plugin','')
    end

    def public_path(file = '')
      compute_public_path((public_name + '/' + file), 'plugins')
    end

    def root_path
      Rails.root+'/plugins/'+public_name
    end

    # Here the developer should specify the meta-informations that the plugin can
    # inform.
    def plugin_name
      self.name.underscore.humanize
    end
    def plugin_description
      _("No description informed.")
    end

    def admin_url
      {:controller => "#{name.underscore}_admin", :action => 'index'}
    end

    def has_admin_url?
      File.exists?(File.join(root_path, 'controllers', "#{name.underscore}_admin_controller.rb"))
    end
  end

  def expanded_template(file_path, locals = {})
    views_path = "#{RAILS_ROOT}/plugins/#{self.class.public_name}/views"
    ERB.new(File.read("#{views_path}/#{file_path}")).result(binding)
  end

  # Here the developer may specify the events to which the plugins can
  # register and must return true or false. The default value must be false.

  # -> If true, noosfero will include plugin_dir/public/style.css into
  # application
  def stylesheet?
    false
  end

  # Here the developer should specify the events to which the plugins can
  # register to. Must be explicitly defined its returning
  # variables.

  # -> Adds buttons to the control panel
  # returns = { :title => title, :icon => icon, :url => url }
  #   title = name that will be displayed.
  #   icon  = css class name (for customized icons include them in a css file).
  #   url   = url or route to which the button will redirect.
  def control_panel_buttons
    nil
  end

  # -> Adds tabs to the profile
  # returns   = { :title => title, :id => id, :content => content, :start => start }
  #   title   = name that will be displayed.
  #   id      = div id.
  #   content = content of the tab (use expanded_template method to import content from another file).
  #   start   = boolean that specifies if the tab must come before noosfero tabs (optional).
  def profile_tabs
    nil
  end

  # -> Adds content to calalog item
  # returns = lambda block that creates a html code
  def catalog_item_extras(item)
    nil
  end

  # -> Adds content to products info
  # returns = lambda block that creates a html code
  def product_info_extras(product)
    nil
  end

  # -> Adds content to products on asset list
  # returns = lambda block that creates a html code
  def asset_product_extras(product, enterprise)
    nil
  end

  # -> Adds content to the beginning of the page
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def body_beginning
    nil
  end

  # -> Add plugins' javascript files to application
  # returns = ['example1.js', 'javascripts/example2.js', 'example3.js']
  def js_files
    []
  end

  # -> Parse and possibly make changes of content (article, block, etc) during HTML rendering
  # returns = content as string after parser and changes
  def parse_content(raw_content)
    raw_content
  end

end
