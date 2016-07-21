module Api
  module V1
    class Roles < Grape::API
      before { authenticate! }

      MAX_PER_PAGE = 50

      resource :organizations do
        segment "/:organization_id" do
          resource :roles do

            paginate max_per_page: MAX_PER_PAGE
            get do
              organization = environment.profiles.find(params[:organization_id])
              roles = Profile::Roles.organization_roles(organization.environment.id, organization.id)
              present_partial paginate(roles), with: Entities::Role
            end
            
          end
        end
      end
    end
  end
end
