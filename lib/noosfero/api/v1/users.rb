module Noosfero
  module API
    module V1
      class Users < Grape::API
        before { authenticate! }

        resource :users do

          #FIXME make the pagination
          #FIXME put it on environment context
          get do
            present environment.users, :with => Entities::User
          end

          # Example Request:
          #  POST api/v1/users?user[login]=some_login&user[password]=some
          post do
            user = User.new(params[:user])
            user.terms_of_use = environment.terms_of_use
            user.environment = environment
            if !user.save
              render_api_errors!(user.errors.full_messages)
            end

            present user, :with => Entities::User
          end

          get "/me" do
            present current_user, :with => Entities::User
          end

          get ":id" do
            present environment.users.find_by_id(params[:id]), :with => Entities::User
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
