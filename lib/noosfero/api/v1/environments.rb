module Noosfero
  module API
    module V1
      class Environments < Grape::API
  
        resource :environment do
  
          desc "Return the person information"
          get '/signup_person_fields' do
            present environment.signup_person_fields
          end

          get ':id' do
            resultEnvironment = nil
            if (params[:id] == "default")
              resultEnvironment = Environment.default
            elsif (params[:id] == "context")
              resultEnvironment = environment
            else
              resultEnvironment = Environment.find(params[:id])
            end
            is_admin = is_admin?(resultEnvironment)
            present resultEnvironment, :with => Entities::Environment, :is_admin => is_admin?(resultEnvironment)
          end

        end
  
      end
    end
  end
end
