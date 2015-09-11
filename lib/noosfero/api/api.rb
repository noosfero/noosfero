require 'grape'
#require 'rack/contrib'

Dir["#{Rails.root}/lib/noosfero/api/*.rb"].each {|file| require file unless file =~ /api\.rb/}
module Noosfero
  module API
    class API < Grape::API
      use Rack::JSONP

      logger = Logger.new(File.join(Rails.root, 'log', "#{ENV['RAILS_ENV'] || 'production'}_api.log"))
      logger.formatter = GrapeLogging::Formatters::Default.new
      #use GrapeLogging::Middleware::RequestLogger, { logger: logger }

      rescue_from :all do |e|
        logger.error e
      end

      @@NOOSFERO_CONF = nil

      def self.NOOSFERO_CONF
        if @@NOOSFERO_CONF
          @@NOOSFERO_CONF
        else
          file = Rails.root.join('config', 'noosfero.yml')
          @@NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[Rails.env] || {} : {}
        end
      end

      before { setup_multitenancy }
      before { detect_stuff_by_domain }
      before { filter_disabled_plugins_endpoints }
      after { set_session_cookie }

      version 'v1'
      prefix "api"
      format :json
      content_type :txt, "text/plain"

      helpers APIHelpers

      mount V1::Articles
      mount V1::Comments
      mount V1::Communities
      mount V1::People
      mount V1::Enterprises
      mount V1::Categories
      mount V1::Tasks
      mount Session

      # hook point which allow plugins to add Grape::API extensions to API::API
      #finds for plugins which has api mount points classes defined (the class should extends Grape::API)
      @plugins = Noosfero::Plugin.all.map { |p| p.constantize }
      @plugins.each do |klass|
        if klass.public_methods.include? :api_mount_points
          klass.api_mount_points.each do |mount_class|
              mount mount_class if mount_class && ( mount_class < Grape::API )
          end
        end
      end

      def self.endpoint_unavailable?(endpoint, environment)
        api_class = endpoint.options[:app] || endpoint.options[:for]
        if api_class.present?
          klass = api_class.name.deconstantize.constantize
          return klass < Noosfero::Plugin && !environment.plugin_enabled?(klass)
        end
      end

      class << self
        def endpoints_with_plugins(environment = nil)
          if environment.present?
            cloned_endpoints = endpoints_without_plugins.dup
            cloned_endpoints.delete_if { |endpoint| endpoint_unavailable?(endpoint, environment) }
          else
            endpoints_without_plugins
          end
        end
        alias_method_chain :endpoints, :plugins
      end
    end
  end
end
