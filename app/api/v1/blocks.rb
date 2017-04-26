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
            present_partial blocks, :with => Entities::Block, current_person: current_person
          else
            error! error.message, 500
          end
        end
      end

      kinds = %w[profile environment]
      kinds.each do |kind|
        resource kind.pluralize.to_sym do
          segment "/:#{kind}_id" do
            resource :blocks do
              get 'available_blocks' do
                  owner = kind=='environment' ? Environment.find(params["#{kind}_id"]) : environment.send(kind.pluralize).find(params["#{kind}_id"])
                  available_blocks = owner.available_blocks(current_person)
                  available_blocks += @plugins.dispatch(:extra_blocks, type: owner.class)
                  present_partial available_blocks, :with => Entities::BlockDefinition, current_person: current_person
              end
            end
          end
        end
      end

    end
  end
end
