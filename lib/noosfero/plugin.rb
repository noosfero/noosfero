require_dependency 'noosfero'
require 'noosfero/plugin/parent_methods'

class Noosfero::Plugin

  attr_accessor :context

  def initialize(context=nil)
    self.context = context
  end

  def environment
    context.environment if self.context
  end

  class << self

    include Noosfero::Plugin::ParentMethods

    attr_writer :should_load

    def should_load
      @should_load.nil? && true || @boot
    end

    def initialize!
      return if !should_load

      klasses = available_plugins.map do |plugin_dir|
        plugin_name = File.basename(plugin_dir)
        load_plugin plugin_name
      end
      available_plugins.each do |plugin_dir|
        load_plugin_extensions plugin_dir
      end
      # filters must be loaded after all extensions
      klasses.each do |plugin|
        load_plugin_filters plugin
        load_plugin_hotspots plugin
      end
    end

    def setup(config)
      return if !should_load
      available_plugins.each do |dir|
        setup_plugin(dir, config)
      end
    end

    def setup_plugin(dir, config)
      plugin_name = File.basename(dir)

      plugin_dependencies_ok = true
      plugin_dependencies_file = File.join(dir, 'dependencies.rb')
      if File.exists?(plugin_dependencies_file)
        begin
          require plugin_dependencies_file
        rescue LoadError => ex
          plugin_dependencies_ok = false
          $stderr.puts "W: Noosfero plugin #{plugin_name} failed to load (#{ex})"
        end
      end

      if plugin_dependencies_ok
        %w[
            controllers
            controllers/public
            controllers/profile
            controllers/myprofile
            controllers/admin
        ].each do |folder|
          config.autoload_paths << File.join(dir, folder)
        end
        [ config.autoload_paths, $:].each do |path|
          path << File.join(dir, 'models')
          path << File.join(dir, 'lib')
          # load vendor/plugins
          Dir.glob(File.join(dir, '/vendor/plugins/*')).each do |vendor_plugin|
            path << "#{vendor_plugin}/lib"
          end
        end
        Dir.glob(File.join(dir, '/vendor/plugins/*')).each do |vendor_plugin|
          init = "#{vendor_plugin}/init.rb"
          require init.gsub(/.rb$/, '') if File.file? init
        end

        # add view path
        config.paths['app/views'].unshift File.join(dir, 'views')
      end
    end

    def load_plugin_identifier identifier
      klass = identifier.to_s.camelize.constantize
      klass = klass.const_get :Base if klass.class == Module
      klass
    end

    def load_plugin public_name
      load_plugin_identifier "#{public_name.to_s.camelize}Plugin"
    end

    # This is a generic method that initialize any possible filter defined by a
    # plugin to a specific controller
    def load_plugin_filters(plugin)
      ActionDispatch::Reloader.to_prepare do
        filters = plugin.new.send 'application_controller_filters' rescue []
        Noosfero::Plugin.add_controller_filters ApplicationController, plugin, filters

        plugin_methods = plugin.instance_methods.select {|m| m.to_s.end_with?('_filters')}
        plugin_methods.each do |plugin_method|
          controller_class = plugin_method.to_s.gsub('_filters', '').camelize.constantize

          filters = plugin.new.send(plugin_method)
          Noosfero::Plugin.add_controller_filters controller_class, plugin, filters
        end
      end
    end

    # This is a generic method to extend the hotspots list with plugins
    # hotspots. This allows plugins to extend other plugins.
    # To use this, the plugin must define its hotspots inside a module Hotspots.
    # Its also needed to include Noosfero::Plugin::HotSpot module
    # in order to dispatch plugins methods.
    #
    # Checkout FooPlugin for usage example.
    def load_plugin_hotspots(plugin)
      ActionDispatch::Reloader.to_prepare do
        begin
          module_name = "#{plugin.name}::Hotspots"
          Noosfero::Plugin.send(:include, module_name.constantize)
        rescue NameError
        end
      end
    end

    def add_controller_filters(controller_class, plugin, filters)
      unless filters.is_a?(Array)
        filters = [filters]
      end
      filters.each do |plugin_filter|
        plugin_filter[:options] ||= {}
        plugin_filter[:options][:if] = -> { environment.plugin_enabled? plugin.module_name }

        filter_method = "#{plugin.identifier}_#{plugin_filter[:method_name]}".to_sym
        controller_class.send plugin_filter[:type], filter_method, plugin_filter[:options]
        controller_class.send :define_method, filter_method, &plugin_filter[:block]
      end
    end

    def load_plugin_extensions(dir)
      ActionDispatch::Reloader.to_prepare do
        Dir[File.join(dir, 'lib', 'ext', '**', '*.rb')].each{ |file| require_dependency file }
      end
    end

    def available_plugins
      unless @available_plugins
        path = File.join(Rails.root, '{baseplugins,config/plugins}', '*')
        @available_plugins = Dir.glob(path).select{ |i| File.directory?(i) }
        if (Rails.env.test? || Rails.env.cucumber?) && !@available_plugins.include?(File.join(Rails.root, 'config', 'plugins', 'foo'))
          @available_plugins << File.join(Rails.root, 'plugins', 'foo')
        end
      end
      @available_plugins
    end

    def available_plugin_names
      available_plugins.map { |f| File.basename(f).camelize }
    end

    def all
      @all ||= available_plugins.map{ |dir| (File.basename(dir) + "_plugin").camelize }
    end
  end

  def has_block?(block)
    self.class.extra_blocks.keys.include?(block)
  end

  def expanded_template(file_path, locals = {})
    views_path = Rails.root.join('plugins', "#{self.class.public_name}", 'views')
    ERB.new(File.read("#{views_path}/#{file_path}")).result(binding)
  end

  def extra_blocks(params = {})
    return [] if self.class.extra_blocks.nil?
    blocks = self.class.extra_blocks.map do |block, options|
      type = options[:type]
      type = type.is_a?(Array) ? type : [type].compact
      type = type.map do |x|
        x.is_a?(String) ? x.capitalize.constantize : x
      end
      raise "This is not a valid type" if !type.empty? && (type.any?{|t| !(t < Profile) && t != Environment })

      position = options[:position]
      position = position.is_a?(Array) ? position : [position].compact
      position = position.map{|p| p.to_i}
      raise "This is not a valid position" if !position.empty? && ![1,2,3].detect{|m| position.include?(m)}

      if !type.empty? && (params[:type] != :all)
        block = type.include?(params[:type]) ? block : nil
      end

      if !position.empty? && !params[:position].nil?
        block = position.detect{ |p| [params[:position]].flatten.include?(p)} ? block : nil
      end

      block
    end
    blocks.compact!
    blocks || []
  end

  def macros
    self.class.constants.map do |constant_name|
      self.class.const_get(constant_name)
    end.select {|const| const.is_a?(Class) && const < Noosfero::Plugin::Macro}
  end

  # Here the developer may specify the events to which the plugins can
  # register and must return true or false. The default value must be false.
  # Must also explicitly define its returning variables.

  # -> If true, noosfero will include plugin_dir/public/style.css into
  # application
  def stylesheet?
    false
  end

  # -> Adds buttons to the control panel
  # returns        = { :title => title, :icon => icon, :url => url }
  #   title        = name that will be displayed.
  #   icon         = css class name (for customized icons include them in a css file).
  #   url          = url or route to which the button will redirect.
  #   html_options = aditional html options.
  def control_panel_buttons
    nil
  end

  # -> Customize profile block design and behavior
  # (overwrites profile_image_link function)
  # returns = lambda block that creates html code.
  def profile_image_link(profile, size, tag, extra_info)
    nil
  end

  # -> Customize the way comments are counted for Profiles and Environment
  # considering more than just articles comments
  # Used on statistic block
  # Ex: a plugin may want that Communities receive comments themselves
  # as evaluations
  # returns = the number of comments to be sum on the statistics
  def more_comments_count owner
    nil
  end

  # -> Adds tabs to the profile
  # returns   = { :title => title, :id => id, :content => content, :start => start }
  #   title   = name that will be displayed.
  #   id      = div id.
  #   content = lambda block that creates html code.
  #   start   = boolean that specifies if the tab must come before noosfero tabs (optional).
  def profile_tabs
    nil
  end

  # -> Adds plugin-specific content types to CMS
  # returns  = [ContentClass1, ContentClass2, ...]
  def content_types
    nil
  end

  # -> Adds tabs to the products
  # returns   = { :title => title, :id => id, :content => content }
  #   title   = name that will be displayed.
  #   id      = div id.
  #   content = lambda block that creates html code.
  def product_tabs product
    nil
  end

  # -> Adds content to calalog item
  # returns = lambda block that creates html code
  def catalog_item_extras(item)
    nil
  end

  # -> Filters the types of organizations that are shown on manage organizations
  # returns a scope filtered by the specified type
  def filter_manage_organization_scope type
    nil
  end

  # -> Add new options for manage organization filters
  # returns an array of new options
  # i.e [[_('Type'), 'type'], [_('Type2'), 'type2']]
  def organization_types_filter_options
    nil
  end
  # -> Adds content to profile editor info and settings
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def profile_editor_extras
    nil
  end

  # -> Adds content to catalog list item
  # returns = lambda block that creates html code
  def catalog_list_item_extras(item)
    nil
  end

  # -> Adds content to products info
  # returns = lambda block that creates html code
  def product_info_extras(product)
    nil
  end

  # -> Adds content to products on asset list
  # returns = lambda block that creates html code
  def asset_product_extras(product)
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

  # -> Adds content to the ending of the page
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def body_ending
    nil
  end

  # -> Adds content to the ending of the page head
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def head_ending
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
  def parse_content(html, source)
    [html, source]
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

  # This method will be called just before a comment is saved to the database.
  #
  # It can modify the comment in several ways. In special, a plugin can call
  # reject! on the comment and that will cause the comment to not be saved.
  #
  # example:
  #
  #   def filter_comment(comment)
  #     if user_not_logged_in
  #       comment.reject!
  #     end
  #   end
  #
  def filter_comment(comment)
  end

  # Define custom logic to filter loaded comments.
  #
  # Example:
  #
  #   def unavailable_comments(scope)
  #     scope.without_spams
  #   end
  #
  def unavailable_comments(scope)
    scope
  end

  # -> Allows plugins to check weather object is a spam
  def check_for_spam(object)
  end

  # -> Allows plugins to know when an object is marked as a spam
  def marked_as_spam(object)
  end

  # -> Allows plugins to know when an object is marked as a ham
  def marked_as_ham(object)
  end

  # Adds extra actions for comments
  # returns = list of hashes or lambda block that creates a list of hashes
  # example:
  #
  #   def comment_actions(comment)
  #     [{:link => link_to_function(...)}]
  #   end
  #
  def comment_actions(comment)
    nil
  end

  # This method is called when the user click on comment actions menu.
  # returns = list or lambda block that return ids of enabled menu items for comments
  # example:
  #
  #   def check_comment_actions(comment)
  #     ['#action1', '#action2']
  #   end
  #
  def check_comment_actions(comment)
    []
  end

  # -> Adds aditional action buttons to article
  # returns = { :title => title, :icon => icon, :url => url, :html_options => {} }
  #   title         = name that will be displayed.
  #   icon          = css class name (for customized icons include them in a css file).
  #   url           = url or route to which the button will redirect.
  #   html_options  = Html options for customization
  #
  # Multiple values could be passed as parameter.
  # returns = [{:title => title, :icon => icon}, {:title => title, :icon => icon}]
  def article_extra_toolbar_buttons(article)
    []
  end

  # -> Adds adicional content to article
  # returns = lambda block that creates html code
  def article_extra_contents(article)
    nil
  end

  # -> Adds adicional fields to a view
  # returns = proc block that creates html code
  def upload_files_extra_fields(article)
    nil
  end

  # -> Adds fields to the signup form
  # returns = proc that creates html code
  def signup_extra_contents
    nil
  end

  # -> Adds adicional content to profile info
  # returns = lambda block that creates html code
  def profile_info_extra_contents
    nil
  end

  # -> Removes the invite friend button from the friends controller
  # returns = boolean
  def remove_invite_friends_button
    nil
  end

  # -> Extends organization list of members
  # returns = An instance of ActiveRecord::NamedScope::Scope retrieved through
  # Person.members_of method.
  def organization_members(organization)
    nil
  end

  # -> Extends person memberships list
  # returns = An instance of ActiveRecord::NamedScope::Scope retrived through
  # Person.memberships_of method.
  def person_memberships(person)
    nil
  end

  # -> Extends person permission access
  # returns = boolean
  def has_permission?(person, permission, target)
    nil
  end

  # -> Adds hidden_fields to the new community view
  # returns = {key => value}
  def new_community_hidden_fields
    nil
  end

  # -> Adds hidden_fields to the enterprise registration view
  # returns = {key => value}
  def enterprise_registration_hidden_fields
    nil
  end

  # -> Add an alternative authentication method.
  # Your plugin have to make the access control and return the logged user.
  # returns = User
  def alternative_authentication
    nil
  end

  # -> Adds adicional link to make the user authentication
  # returns = lambda block that creates html code
  def alternative_authentication_link
    nil
  end

  # -> Allow or not user registration
  # returns = boolean
  def allow_user_registration
    true
  end

  # -> Allow or not password recovery by users
  # returns = boolean
  def allow_password_recovery
    true
  end

  # -> Adds fields to the login form
  # returns = proc that creates html code
  def login_extra_contents
    nil
  end

  # -> Adds adicional content to comment form
  # returns = lambda block that creates html code
  def comment_form_extra_contents(args)
    nil
  end

  # -> Adds adicional content to article header
  # returns = lambda block that creates html code
  def article_header_extra_contents(article)
    nil
  end

  # -> Adds adittional content to comment visualization
  # returns = lambda block that creates html code
  def comment_extra_contents(args)
    nil
  end

  # This method is called when the user clicks to send a comment.
  # A plugin can add new content to comment form and this method can process the params sent to avoid creating field on core tables.
  # returns = params after processed by plugins
  # example:
  #
  #   def process_extra_comment_params(params)
  #     params.delete(:extra_field)
  #   end
  #
  def process_extra_comment_params(params)
    params
  end

  # -> Finds objects by their contents
  # returns = {:results => [a, b, c, ...], ...}
  # P.S.: The plugin might add other informations on the return hash for its
  # own use in specific views
  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    scope = scope.like_search(query, options) unless query.blank?
    scope = scope.send(options[:filter]) unless options[:filter].blank?
    {:results => scope.paginate(paginate_options)}
  end

  # -> Suggests terms based on asset and query
  # returns = [a, b, c, ...]
  def find_suggestions(query, context, asset, options={:limit => 5})
    context.search_terms.
      where(:asset => asset).
      where("search_terms.term like ?", "%#{query}%").
      where('search_terms.score > 0').
      order('search_terms.score DESC').
      limit(options[:limit]).map(&:term)
  end

  # -> Adds aditional fields for change_password
  # returns = [{:field => 'field1', :name => 'field 1 name', :model => 'person'}, {...}]
  def change_password_fields
    nil
  end

  # -> Perform extra transactions related to profile in profile editor
  # returns = true in success or raise an exception if it could not update the data
  def profile_editor_transaction_extras
    nil
  end

  # -> Return a list of hashs with the needed information to create optional fields
  # returns = a list of hashs as {:name => "string", :label => "string", :object_name => :key, :method => :key}
  def extra_optional_fields
    []
  end

  # -> Adds css class to <html> tag
  # returns = ['class1', 'class2']
  def html_tag_classes
    nil
  end

  # -> Adds additional blocks to profiles and environments.
  # Your plugin must implements a class method called 'extra_blocks'
  # that returns a hash with the following syntax.
  #    {
  #      'block_name' =>
  #        {
  #          :type => 'for which holder the block will be available',
  #          :position => 'where the block could be displayed'
  #        }
  #    }
  #
  # Where:
  #
  #   - block_name: Name of the new block added to the blocks list
  #   - type: Might have some of the values
  #      - 'environment' or Environment: If the block is available only for Environment models
  #      - 'community' or Community: If the block is available only for Community models
  #      - 'enterprise' or Enterprise: If the block is available only for Enterprise models
  #      - 'person' or Person: If the block is available only for Person models
  #      - nil: If no type parameter is passed the block will be available for all types
  #   - position: Is the layout position of the block. It should be:
  #      - '1' or 1: Area 1 of layout
  #      - '2' or 2: Area 2 of layout
  #      - '3' or 3: Area 3 of layout
  #      - nil: If no position parameter is passed the block will be available for all positions
  #
  #      OBS: Area 1 is where stay the main content of layout. Areas 2 and 3 are the sides of layout.
  #
  # examples:
  #
  #   def self.extra_blocks(params)
  #     {
  #       #Display 'CustomBlock1' only for 'Person' on position '1'
  #       CustomBlock1 => {:type => 'person', :position => '1' },
  #
  #       #Display 'CustomBlock2' only for 'Community' on position '2'
  #       CustomBlock2 => {:type => Community, :position => '2' },
  #
  #       #Display 'CustomBlock3' only for 'Enterprise' on position '3'
  #       CustomBlock3 => {:type => 'enterprise', :position => 3 },
  #
  #       #Display 'CustomBlock2' for 'Environment' and 'Person' on positions '1' and '3'
  #       CustomBlock4 => {:type => ['environment', Person], :position => ['1','3'] },
  #
  #       #Display 'CustomBlock5' for all types and all positions
  #       CustomBlock5 => {},
  #     }
  #   end
  #
  #   OBS: The default value is a empty hash.
  def self.extra_blocks
    {}
  end

  def method_missing(method, *args, &block)
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
    if method.to_s =~ /^(.+)_controller_filters$/
      []
    # -> Removes the action button from the content
    # returns = boolean
    elsif method.to_s =~ /^content_remove_(#{content_actions.join('|')})$/
      nil
    # -> Expire the action button from the content
    # returns = string with reason of expiration
    elsif method.to_s =~ /^content_expire_(#{content_actions.join('|')})$/
      nil
    # -> Generic hotspots for models callbacks
    # Example: article_after_create_callback
    elsif method.to_s =~ /^(.+)_#{Noosfero::Plugin::HotSpot::CALLBACK_HOTSPOTS.join('|')}_callback$/
      nil
    elsif context.respond_to?(method)
      context.send(method)
    else
      super
    end
  end

  private

  def content_actions
    #FIXME 'new' and 'upload' only works for content_remove. It should work for
    #content_expire too.
    %w[edit delete spread locale suggest home new upload undo clone]
  end

end

require 'noosfero/plugin/hot_spot'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/settings'
