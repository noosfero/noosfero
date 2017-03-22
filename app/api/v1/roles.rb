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
              person_roles = []
              if params[:person_id].present?
                person = environment.people.find(params[:person_id])
                person_roles = person.role_assignments.where(resource: profile).joins(:role).map(&:role)
              end
              present_partial paginate(roles), with: Entities::Role, person_roles: person_roles
            end

            resource :assign do
              post do
                profile = environment.profiles.find(params[:profile_id])
                return forbidden! unless profile.kind_of?(Organization)

                person = environment.people.find(params[:person_id])
                profile.affiliate(person, Role.find(params[:role_ids])) if params[:role_ids].present?
                profile.disaffiliate(person, Role.find(params[:remove_role_ids])) if params[:remove_role_ids].present?
                person_roles = person.role_assignments.where(resource: profile).joins(:role).map(&:role)
                present_partial paginate(person_roles), with: Entities::Role
              end
            end

          end
        end
      end
    end
  end
end
