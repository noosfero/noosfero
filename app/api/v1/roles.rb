module Api
  module V1
    class Roles < Grape::API
      before { authenticate! }

      MAX_PER_PAGE = 50

      resource :profiles do
        segment "/:profile_id" do
          resource :roles do

            paginate max_per_page: MAX_PER_PAGE
            get do
              profile = environment.profiles.find(params[:profile_id])
              return forbidden! unless profile.kind_of?(Organization)
              roles = Profile::Roles.organization_roles(profile.environment.id, profile.id)
              present_partial paginate(roles), with: Entities::Role
            end
            
          end
        end
      end
    end
  end
end
