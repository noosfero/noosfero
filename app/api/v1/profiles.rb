module Api
  module V1
    class Profiles < Grape::API

      resource :profiles do

        get do
          profiles = select_filtered_collection_of(environment, 'profiles', params)
          profiles = profiles.visible
          profiles = profiles.by_location(params) # Must be the last. May return Exception obj.
          present profiles, :with => Entities::Profile, :current_person => current_person
        end

        get ':id', requirements: { id: /#{Noosfero.identifier_format}/ } do
          profiles = environment.profiles
          profiles = profiles.visible
          key = params[:key].to_s == "identifier" ? :identifier : :id

          profile = profiles.find_by key => params[:id]

          if profile
            type_map = {
              Person => Entities::Person,
              Community => Entities::Community,
              Enterprise => Entities::Enterprise
            }[profile.class] || Entities::Profile

            present profile, :with => type_map, :current_person => current_person
          else
            not_found!
          end
        end

        desc "Update profile information"
        post ':id' do
          authenticate!
          profile = environment.profiles.find_by(id: params[:id])
          return forbidden! unless profile.allow_edit?(current_person)
          begin
            profile_params = asset_with_image(params[:profile])
            profile.update_attributes!(asset_with_custom_image(:top_image, profile_params))
            present profile, :with => Entities::Profile, :current_person => current_person
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(profile.errors)
          end
        end

        delete ':id' do
          authenticate!
          profiles = environment.profiles
          profile = profiles.find_by id: params[:id]

          not_found! if profile.blank?

          if profile.allow_destroy?(current_person)
            present({ success: profile.destroy })
          else
            forbidden!
          end
        end
      end
    end
  end
end
