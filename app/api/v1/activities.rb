module Api
  module V1
    class Activities < Grape::API

      resource :profiles do

        get ':id/activities' do
          profile = environment.profiles.find_by id: params[:id]
          present_activities_for_asset(profile)
        end
      end
    end
  end
end
