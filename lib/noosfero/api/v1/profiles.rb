module Noosfero
  module API
    module V1
      class Profiles < Grape::API
        before { authenticate! }

        resource :profiles do

          get do
            profiles = select_filtered_collection_of(environment, 'profiles', params)
            profiles = profiles.visible_for_person(current_person)
            profiles = profiles.by_location(params) # Must be the last. May return Exception obj.
            present profiles, :with => Entities::Profile, :current_person => current_person
          end

          get ':id' do
            profiles = environment.profiles
            profiles = profiles.visible_for_person(current_person)
            profile = profiles.find_by id: params[:id]
            present profile, :with => Entities::Profile, :current_person => current_person
          end
        end
      end
    end
  end
end
