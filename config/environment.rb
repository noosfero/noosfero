# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# locally-developed modules
require 'locale'
require 'gettext/rails'
require 'acts_as_filesystem'
require 'acts_as_having_settings'
require 'acts_as_searchable'
require 'acts_as_having_boxes'
require 'acts_as_having_image'
require 'will_paginate'
require 'route_if'

# extra directories for controllers organization 
extra_controller_dirs = %w[
  app/controllers/my_profile
  app/controllers/admin
  app/controllers/system
  app/controllers/public
].map {|item| File.join(RAILS_ROOT, item) }

def noosfero_session_secret
  file = File.join(File.dirname(__FILE__), 'session.secret')
  if !File.exists?(file)
    secret = (1..128).map { %w[0 1 2 3 4 5 6 7 8 9 a b c d e f][rand(16)] }.join('')
    File.open(file, 'w') do |f|
      f.puts secret
    end
  end
  File.read(file).strip
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

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

  # don't load the sweepers while loading the database
  unless $PROGRAM_NAME =~ /rake$/ && ARGV.first == 'db:schema:load'
    config.active_record.observers = :article_sweeper, :role_assignment_sweeper, :friendship_sweeper, :category_sweeper
  end
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_noosfero_session',
    :secret      => noosfero_session_secret(),
  }

  # Adds custom attributes to the Set of allowed html attributes for the #sanitize helper
  config.action_view.sanitized_allowed_attributes = 'align', 'border', 'alt', 'vspace', 'hspace', 'width', 'heigth', 'value', 'type', 'data', 'style', 'target'
  
   # Adds custom tags to the Set of allowed html tags for the #sanitize helper
  config.action_view.sanitized_allowed_tags = 'object', 'embed', 'param', 'table', 'tr', 'th', 'td'

  # See Rails::Configuration for more options

  extra_controller_dirs.each do |item|
    $LOAD_PATH << item
    config.controller_paths << item
  end
end
extra_controller_dirs.each do |item|
  Dependencies.load_paths << item
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



Noosfero.locales = {
  'en' => 'English',
  'pt_BR' => 'Português',
  'fr' => 'Français',
  'hy' => 'հայերեն լեզու',
}
# if you want to override this, do it in config/local.rb !
Noosfero.default_locale = 'en'

Tag.hierarchical = true

# several local libraries
require 'noosfero'
require 'sqlite_extension'

# load a local configuration if present, but not under test environment.
if ENV['RAILS_ENV'] != 'test'
  localconfigfile = File.join(RAILS_ROOT, 'config', 'local.rb')
  if File.exists?(localconfigfile)
    require localconfigfile
  end
end
