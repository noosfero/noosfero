module Api
  module V1
    class Activities < Grape::API
      before { authenticate! }

      resource :profiles do

        get ':id/activities' do
          profile = Profile.find_by id: params[:id]

          not_found! if profile.blank? || profile.secret || !profile.visible
          forbidden! if !profile.secret && profile.visible && !profile.display_private_info_to?(current_person)

          activities = profile.activities.map(&:activity)
          present activities, :with => Entities::Activity, :current_person => current_person
        end
      end
    end
  end
end
