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
      File.join(RAILS_ROOT, 'plugins', public_name)
    end

    def view_path
      File.join(root_path,'views')
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
  #   content = lambda block that creates a html code.
  #   start   = boolean that specifies if the tab must come before noosfero tabs (optional).
  def profile_tabs
    nil
  end

  # -> Adds content to calalog item
  # returns = lambda block that creates a html code
  def catalog_item_extras(item)
    nil
  end

  # -> Adds content to calalog list item
  # returns = lambda block that creates a html code
  def catalog_list_item_extras(item)
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

  # -> Adds a property to the product on asset products
  # returns = {:name => name, :content => content}
  #   name = Name of the property
  #   content = lambda block that creates an html
  def asset_product_properties(product)
    nil
  end

  # -> Adds content to the beginning of the page
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def body_beginning
    nil
  end

  # -> Adds plugins' javascript files to application
  # returns = ['example1.js', 'javascripts/example2.js', 'example3.js']
  def js_files
    []
  end

  # -> Adds stuff in user data hash
  # returns = { :some_data => some_value, :another_data => another_value }
  def user_data_extras
    {}
  end

  # -> Parse and possibly make changes of content (article, block, etc) during HTML rendering
  # returns = content as string after parser and changes
  def parse_content(raw_content)
    raw_content
  end

  # -> Adds links to the admin panel
  # returns = {:title => title, :url => url}
  #   title = name that will be displayed in the link
  #   url   = url or route to which the link will redirect to.
  def admin_panel_links
    nil
  end

  # -> Adds buttons to manage members page
  # returns = { :title => title, :icon => icon, :url => url }
  #   title = name that will be displayed.
  #   icon  = css class name (for customized icons include them in a css file).
  #   url   = url or route to which the button will redirect.
  def manage_members_extra_buttons
    nil
  end

  # This is a generic hotspot for all controllers on Noosfero.
  # If any plugin wants to define filters to run on any controller, the name of
  # the hotspot must be in the following form: <underscored_controller_name>_filters.
  # Example: for ProfileController the hotspot is profile_controller_filters
  #
  # -> Adds a filter to a controller
  # returns = { :type => type,
  #             :method_name => method_name,
  #             :options => {:opt1 => opt1, :opt2 => opt2},
  #             :block => Proc or lambda block}
  #   type = 'before_filter' or 'after_filter'
  #   method_name = The name of the filter
  #   option = Filter options, like :only or :except
  #   block = Block that the filter will call
  def method_missing(method, *args, &block)
    if method.to_s =~ /^(.+)_controller_filters$/
      []
    else
      super
    end
  end

end
