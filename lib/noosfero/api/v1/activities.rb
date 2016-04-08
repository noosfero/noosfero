module Noosfero
  module API
    module V1
      class Activities < Grape::API
        before { authenticate! }

        resource :profiles do

          get ':id/activities' do
            profile = environment.profiles
            profile = profile.visible_for_person(current_person) if profile.respond_to?(:visible_for_person)
            profile = profile.find_by id: params[:id]
            activities = profile.activities.map(&:activity)
            present activities, :with => Entities::Activity, :current_person => current_person
          end
        end
      end
    end
  end
end
