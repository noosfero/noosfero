# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

require 'gettext/rails'
#require 'extended_tag'
Tag.hierarchical = true

Comatose.configure do |config|
  config.admin_get_root_page do 
    Comatose::Page.find_by_path(request.parameters[:profile])
  end
  config.admin_authorization do |config|
    Profile.exists?(:identifier => request.parameters[:profile])
    # FIXME: also check permissions
  end
  config.admin_includes << :authenticated_system
  config.admin_helpers << :application_helper
end
Comatose::AdminController.design :holder => 'virtual_community'
Comatose::AdminController.before_filter do |controller|
  # TODO: copy/paste; extract this into a method (see
  # app/controllers/application.rb)
  domain = Domain.find_by_name(controller.request.host)
  if domain.nil?
    virtual_community = VirtualCommunity.default
  else
    virtual_community = domain.virtual_community
    profile = domain.profile
  end
  controller.instance_variable_set('@virtual_community', virtual_community)
end

# taken from http://blog.spotstory.com/2007/04/19/upgrading-to-rails-12/
# Array of plugins with Application model dependencies.
reloadable_plugins = ["design"]
# Force these plugins to reload, avoiding stale object references.
reloadable_plugins.each do |plugin_name|
  reloadable_path = RAILS_ROOT + "/vendor/plugins/#{plugin_name}/lib"
  Dependencies.load_once_paths.delete(reloadable_path)
end
