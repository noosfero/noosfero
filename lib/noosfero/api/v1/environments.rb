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
            if (params[:id] == "default")
              present Environment.default
            elsif (params[:id] == "context")
              present environment
            else
              present Environment.find(params[:id])
            end
          end

        end
  
      end
    end
  end
end
