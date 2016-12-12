module Api
  module V1

    class Blocks < Grape::API
      resource :blocks do
        get ':id' do
          block = Block.find(params["id"])
          return forbidden! unless block.visible_to_user?(current_person) || block.allow_edit?(current_person)
          block.api_content_params = params.except("id")
          present block, :with => Entities::Block, display_api_content: true, current_person: current_person
        end

        post ':id' do
          block = Block.find(params["id"])
          return forbidden! unless block.allow_edit?(current_person)
          block.update_attributes!(asset_with_images(params[:block]))
          present block, :with => Entities::Block, display_api_content: true, current_person: current_person
        end

        patch do
          error = nil
          blocks = Block.transaction do
            params["blocks"].map do |block_params|
              block = Block.find(block_params["id"])
              return forbidden! unless block.allow_edit?(current_person)
              begin
                block.update_attributes!(asset_with_images(block_params))
              rescue => e
                error = e
                raise ActiveRecord::Rollback
              end
              block
            end
          end
          if error.nil?
            present blocks, :with => Entities::Block, current_person: current_person
          else
            error! error.message, 500
          end
        end
      end
    end

  end
end
