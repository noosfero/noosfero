require 'grape'
#require 'rack/contrib'
Dir["#{Rails.root}/lib/noosfero/api/*.rb"].each {|file| require file unless file =~ /api\.rb/}
module Noosfero
  module API
    class API < Grape::API
      use Rack::JSONP

      logger = Logger.new(File.join(Rails.root, 'log', "#{ENV['RAILS_ENV'] || 'production'}_api.log"))
      logger.formatter = GrapeLogging::Formatters::Default.new
      use RequestLogger, { logger: logger }

      rescue_from :all do |e|
        logger.error e
      end

      before { setup_multitenancy }
      before { detect_stuff_by_domain }
      after { set_session_cookie }

      version 'v1'
      prefix "api"
      format :json
      content_type :txt, "text/plain"
  
      helpers APIHelpers
  
      mount V1::Articles
      mount V1::Comments
      mount V1::Users
      mount V1::Communities
      mount V1::People
      mount V1::Enterprises
      mount V1::Categories
      mount Session
  
      # hook point which allow plugins to add Grape::API extensions to API::API
      #finds for plugins which has api mount points classes defined (the class should extends Grape::API)
      @plugins = Noosfero::Plugin.all.map { |p| p.constantize }
      @plugins.each do |klass|
        if klass.public_methods.include? 'api_mount_points'
          klass.api_mount_points.each do |mount_class|
              mount mount_class if mount_class && ( mount_class < Grape::API )
          end
        end
      end
    end
  end
end
