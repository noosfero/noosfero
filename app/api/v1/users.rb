module Api
  module V1
    class Users < Grape::API

      resource :users do

        get do
          users = select_filtered_collection_of(environment, 'users', params)
          users = users.joins(:person)
                       .merge(Person.accessible_to(current_person))
          present users, :with => Entities::User, :current_person => current_person
        end

        get "/me" do
          authenticate!
          present current_user, :with => Entities::User, :current_person => current_person
        end

        get ":id" do
          user = environment.users.find_by id: params[:id]
          if user
            present user, :with => Entities::User, :current_person => current_person
          else
            not_found!
          end
        end

        patch ":id" do
          authenticate!
          begin
            current_person.user.change_password!(params[:current_password],
                               params[:new_password],
                               params[:new_password_confirmation])
	    present current_person.user, :with => Entities::User, :current_person => current_person
          rescue Exception
            render_model_errors!(current_person.user.errors)
          end

        end

      end

    end
  end
end
