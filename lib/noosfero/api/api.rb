require 'grape'
Dir["#{Rails.root}/lib/noosfero/api/*.rb"].each {|file| require file}
module Noosfero
  module API
    class API < Grape::API
      before { start_log }
      before { setup_multitenancy }
      before { detect_stuff_by_domain }
      after { end_log }
  
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
