module Noosfero
  module API
    module V1

      class Blocks < Grape::API
        resource :blocks do
          get ':id' do
            block = Block.find(params["id"])
            if block.owner.kind_of?(Profile)
              return forbidden! unless block.owner.display_info_to?(current_person)
            end
            present block, :with => Entities::Block
          end
        end
      end

    end
  end
end
