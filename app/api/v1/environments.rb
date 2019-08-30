module Api
  module V1
    class Environments < Grape::API::Instance
      resource :environments do
        desc "Return the person information"
        get "/signup_person_fields" do
          present environment.signup_person_fields
        end

        get ":id" do
          local_environment = nil
          if (params[:id] == "default")
            local_environment = Environment.default
          elsif (params[:id] == "context")
            local_environment = environment
          else
            local_environment = Environment.find(params[:id])
          end
          present_partial local_environment, with: Entities::Environment, is_admin: is_admin?(local_environment), current_person: current_person, params: params
        end

        desc "Update environment information"
        post ":id" do
          authenticate!
          environment = Environment.find_by(id: params[:id])
          return forbidden! unless is_admin?(environment)

          begin
            environment.update_attributes!(params[:environment])
            present_partial environment, with: Entities::Environment, is_admin: is_admin?(environment), current_person: current_person, params: params
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(environment.errors)
          end
        end
      end
    end
  end
end
