module Api
  module V1

    class Blocks < Grape::API

      resource :profiles do
        segment '/:profile_id' do
          resource :blocks do
            resource :preview do
              get do
                block_type = params[:block_type]
                return forbidden! unless block_type.constantize <= Block
                profile = environment.profiles.find_by(id: params[:profile_id])
                box = Box.new(:owner => profile)
                block = block_type.constantize.new(:box => box)
                present_partial block, :with => Entities::Block, display_api_content: true
              end
            end
          end
        end
      end

      resource :blocks do
        get ':id' do
          block = Block.find(params["id"])
          return forbidden! unless block.visible_to_user?(current_person) || block.allow_edit?(current_person)
          present_partial block, :with => Entities::Block, display_api_content: true, current_person: current_person, api_content_params: params.except("id")
        end

        post ':id' do
          block = Block.find(params["id"])
          return forbidden! unless block.allow_edit?(current_person)
          block.update_attributes!(asset_with_images(params[:block]))
          present_partial block, :with => Entities::Block, display_api_content: true, current_person: current_person, api_content_params: params.except("id")
        end
      end

    end
  end
end
