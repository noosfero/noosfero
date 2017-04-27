module Api
  module V1

    class Blocks < Grape::API

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
