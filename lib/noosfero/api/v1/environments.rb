module Noosfero
  module API
    module V1
      class Environments < Grape::API
  
        resource :environment do
  
          desc "Return the person information"
          get '/signup_person_fields' do
            present environment.signup_person_fields
          end

          desc 'Return the tag counts for this environment'
          get '/tags' do
            present environment.tag_counts
          end

          get ':id' do
            local_environment = nil
            if (params[:id] == "default")
              local_environment = Environment.default
            elsif (params[:id] == "context")
              local_environment = environment
            else
              local_environment = Environment.find(params[:id])
            end
            present_partial local_environment, :with => Entities::Environment, :is_admin => is_admin?(local_environment)
          end

        end
  
      end
    end
  end
end
