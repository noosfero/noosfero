module Noosfero
  module API
    module V1
      class Environments < Grape::API
  
        resource :environment do
  
          desc "Return the person information"
          get '/signup_person_fields' do
            present environment.signup_person_fields
          end

          # Returns the given environment
          get ':id' do
            id = params[:id]
            if (id == "default")
              present Environment.default
            else
              if (id == "context")
                present Environment.find_by_name(request.host)
              else
                present Environment.find(params[:id])
              end
            end
          end

        end
  
      end
    end
  end
end
