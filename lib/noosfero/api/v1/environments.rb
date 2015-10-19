module Noosfero
  module API
    module V1
      class Environments < Grape::API
  
        resource :environment do
  
          desc "Return the person information"
          get '/signup_person_fields' do
            present environment.signup_person_fields
          end
  
        end
  
      end
    end
  end
end
