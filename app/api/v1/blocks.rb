module Api
  module V1
    class Blocks < Grape::API::Instance
      resource :profiles do
        segment "/:id" do
          resource :blocks do
            resource :preview do
              get do
                block_type = params[:block_type]
                return forbidden! unless Object.const_defined?(block_type) && block_type.constantize <= Block

                profile = environment.profiles.find_by(id: params[:id])
                return forbidden! unless profile.allow_edit_design?(current_person)

                block = block_type.constantize.new(box: Box.new(owner: profile))
                present_partial block, with: Entities::Block, display_api_content: true
              end
            end
          end
        end
      end

      resource :environments do
        segment "/:id" do
          resource :blocks do
            resource :preview do
              get do
                block_type = params[:block_type]
                return forbidden! unless Object.const_defined?(block_type) && block_type.constantize <= Block

                local_environment = nil
                if (params[:id] == "default")
                  local_environment = Environment.default
                elsif (params[:id] == "context")
                  local_environment = environment
                else
                  local_environment = Environment.find(params[:id])
                end
                return forbidden! unless local_environment.allow_edit_design?(current_person)

                block = block_type.constantize.new(box: Box.new(owner: local_environment))
                present_partial block, with: Entities::Block, display_api_content: true, params: params
              end
            end
          end
        end
      end

      resource :blocks do
        get ":id" do
          block = Block.find(params["id"])
          return forbidden! unless block.visible_to_user?(current_person) || block.allow_edit?(current_person)

          present_partial block, with: Entities::Block, display_api_content: true, current_person: current_person, api_content_params: params.except("id"), params: params
        end

        post ":id" do
          block = Block.find(params["id"])
          return forbidden! unless block.allow_edit?(current_person)

          block.update_attributes!(asset_with_images(params[:block]))
          present_partial block, with: Entities::Block, display_api_content: true, current_person: current_person, api_content_params: params.except("id"), params: params
        end
      end
    end
  end
end
