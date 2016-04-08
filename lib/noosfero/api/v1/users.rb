module Noosfero
  module API
    module V1
      class Users < Grape::API
        before { authenticate! }

        resource :users do

          get do
            users = select_filtered_collection_of(environment, 'users', params)
            users = users.select{|u| u.person.display_info_to? current_person}
            present users, :with => Entities::User, :current_person => current_person
          end

          get "/me" do
            present current_user, :with => Entities::User, :current_person => current_person
          end

          get ":id" do
            user = environment.users.find_by id: params[:id]
            unless user.person.display_info_to? current_person
              unauthorized!
            end
            present user, :with => Entities::User, :current_person => current_person
          end

          get ":id/permissions" do
            user = environment.users.find(params[:id])
            output = {}
            user.person.role_assignments.map do |role_assigment|
              if role_assigment.resource.respond_to?(:identifier) && role_assigment.resource.identifier == params[:profile]
                output[:permissions] = role_assigment.role.permissions
              end
            end
            present output
          end

        end

      end
    end
  end
end
