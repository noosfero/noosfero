require File.expand_path('../boot', __FILE__)

require 'rails/all'

# FIXME this silences the warnings about Rails 2.3-style plugins under
# vendor/plugins, which are deprecated. Hiding those warnings makes it easier
# to work for now, but we should really look at putting those plugins away.
ActiveSupport::Deprecation.silenced = true

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Noosfero
  class Application < Rails::Application

    require 'noosfero/plugin'

    # Adds custom attributes to the Set of allowed html attributes for the #sanitize helper
    config.action_view.sanitized_allowed_attributes = 'align', 'border', 'alt', 'vspace', 'hspace', 'width', 'heigth', 'value', 'type', 'data', 'style', 'target', 'codebase', 'archive', 'classid', 'code', 'flashvars', 'scrolling', 'frameborder', 'controls', 'autoplay'

    # Adds custom tags to the Set of allowed html tags for the #sanitize helper
    config.action_view.sanitized_allowed_tags = 'object', 'embed', 'param', 'table', 'tr', 'th', 'td', 'applet', 'comment', 'iframe', 'audio', 'video', 'source'

    config.action_controller.include_all_helpers = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W( #{Rails.root.join('app', 'sweepers')} )
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/**/"]
    config.autoload_paths += %W( #{Rails.root.join('test', 'mocks', Rails.env)} )


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # Sweepers are observers
    # don't load the sweepers while loading the database
    ignore_rake_commands = %w[
      db:schema:load
      gems:install
      clobber
      noosfero:translations:compile
      makemo
    ]
    if $PROGRAM_NAME =~ /rake$/ && (ignore_rake_commands.include?(ARGV.first))
      Noosfero::Plugin.should_load = false
    else
      config.active_record.observers = :article_sweeper, :role_assignment_sweeper, :friendship_sweeper, :category_sweeper, :block_sweeper
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = nil

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    def noosfero_session_secret
      require 'fileutils'
      target_dir = File.join(File.dirname(__FILE__), '../tmp')
      FileUtils.mkdir_p(target_dir)
      file = File.join(target_dir, 'session.secret')
      if !File.exists?(file)
        secret = (1..128).map { %w[0 1 2 3 4 5 6 7 8 9 a b c d e f][rand(16)] }.join('')
        File.open(file, 'w') do |f|
          f.puts secret
        end
      end
      File.read(file).strip
    end

    # Your secret key for verifying cookie session data integrity.
    # If you change this key, all old sessions will become invalid!
    # Make sure the secret is at least 30 characters and all random, 
    # no regular words or you'll be exposed to dictionary attacks.
    config.secret_token = noosfero_session_secret
    config.action_dispatch.session = {
      :key    => '_noosfero_session',
    }

    Noosfero::Plugin.setup(config)

  end
end
