module Api
  module V1
    class Profiles < Grape::API::Instance
      resource :profiles do
        get do
          profiles = select_filtered_collection_of(environment, "profiles", params)
          profiles = profiles.visible
          profiles = profiles.by_location(params) # Must be the last. May return Exception obj.
          present profiles, with: Entities::Profile, current_person: current_person
        end

        get ":id", requirements: { id: /#{Noosfero.identifier_format}/ } do
          key = params[:key].to_s == "identifier" ? :identifier : :id
          profile = environment.profiles.visible.find_by key => params[:id]

          if profile
            type_map = {
              Person => Entities::Person,
              Community => Entities::Community,
              Enterprise => Entities::Enterprise
            }[profile.class] || Entities::Profile

            present profile, with: type_map, current_person: current_person, params: params
          else
            not_found!
          end
        end

        content_type :binary, "image"
        ["icon", "thumb", "big", "portrait", "minor"].map do |thumb_size|
          get ":id/#{thumb_size}", requirements: { id: /#{Noosfero.identifier_format}/ } do
            key = params[:key].to_s == "identifier" ? :identifier : :id
            profile = environment.profiles.visible.find_by key => params[:id]
            if profile && profile.image && profile.image.data(thumb_size)
              content_type "image"
              present profile.image.data(thumb_size)
            else
              not_found!
            end
          end
        end

        desc "Update profile information"
        post ":id" do
          authenticate!
          profile = environment.profiles.find_by(id: params[:id])
          return forbidden! unless profile.allow_edit?(current_person)

          begin
            profile_params = asset_with_image(params[:profile])
            profile.update_attributes!(asset_with_custom_image(:top_image, profile_params))
            present profile, with: Entities::Profile, current_person: current_person, params: params
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(profile.errors)
          end
        end

        delete ":id" do
          authenticate!
          profiles = environment.profiles
          profile = profiles.find_by id: params[:id]

          not_found! if profile.blank?
          if profile.allow_destroy?(current_person)
            profile.destroy
            output = { success: true }
            output[:message] = _("The profile %s was removed.") % profile.name
            output[:code] = Api::Status::Http::NO_CONTENT
            present output, with: Entities::Response
          else
            forbidden!
          end
        end
      end
    end
  end
end
