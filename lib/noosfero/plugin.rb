require 'noosfero'
include ActionView::Helpers::AssetTagHelper

class Noosfero::Plugin

  attr_accessor :context

  class << self

    def klass(dir)
      (dir.to_s.camelize + 'Plugin').constantize # load the plugin
    end

    def init_system
      enabled_plugins = Dir.glob(File.join(Rails.root, 'config', 'plugins', '*'))
      if Rails.env.test? && !enabled_plugins.include?(File.join(Rails.root, 'config', 'plugins', 'foo'))
        enabled_plugins << File.join(Rails.root, 'plugins', 'foo')
      end
      enabled_plugins.select do |entry|
        File.directory?(entry)
      end.each do |dir|
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
          Rails.configuration.controller_paths << File.join(dir, 'controllers')
          ActiveSupport::Dependencies.load_paths << File.join(dir, 'controllers')
          controllers_folders = %w[public profile myprofile admin]
          controllers_folders.each do |folder|
            Rails.configuration.controller_paths << File.join(dir, 'controllers', folder)
            ActiveSupport::Dependencies.load_paths << File.join(dir, 'controllers', folder)
          end
          [ ActiveSupport::Dependencies.load_paths, $:].each do |path|
            path << File.join(dir, 'models')
            path << File.join(dir, 'lib')
          end

          klass(plugin_name)
        end
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

  # -> Adds content to calalog item
  # returns = lambda block that creates html code
  def catalog_item_extras(item)
    nil
  end

  # -> Adds content to profile editor info and settings
  # returns = lambda block that creates html code or raw rhtml/html.erb
  def profile_editor_extras
    nil
  end

  # -> Adds content to calalog list item
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

  # This method is called by the CommentHandler background job before sending
  # the notification email. If the comment is marked as spam (i.e. by calling
  # <tt>comment.spam!</tt>), then the notification email will *not* be sent.
  #
  # example:
  #
  #   def check_comment_for_spam(comment)
  #     if anti_spam_service.is_spam?(comment)
  #       comment.spam!
  #     end
  #   end
  #
  def check_comment_for_spam(comment)
  end

  # This method is called when the user manually marks a comment as SPAM. A
  # plugin implementing this method should train its spam detection mechanism
  # by submitting this comment as a confirmed spam.
  #
  # example:
  #
  #   def comment_marked_as_spam(comment)
  #     anti_spam_service.train_with_spam(comment)
  #   end
  #
  def comment_marked_as_spam(comment)
  end

  # This method is called when the user manually marks a comment a NOT SPAM. A
  # plugin implementing this method should train its spam detection mechanism
  # by submitting this coimment as a confirmed ham.
  #
  # example:
  #
  #   def comment_marked_as_ham(comment)
  #     anti_spam_service.train_with_ham(comment)
  #   end
  #
  def comment_marked_as_ham(comment)
  end

  # -> Adds fields to the signup form
  # returns = lambda block that creates html code
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
  # returns = lambda block that creates html code
  def login_extra_contents
    nil
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
    else
      super
    end
  end

  private

  def content_actions
    #FIXME 'new' and 'upload' only works for content_remove. It should work for
    #content_expire too.
    %w[edit delete spread locale suggest home new upload]
  end

end
