module Noosfero
  module API
    module V1

      class Boxes < Grape::API

        kinds = %w[profile community person enterprise]
        kinds.each do |kind|

          resource kind.pluralize.to_sym do

            segment "/:#{kind}_id" do
              resource :boxes do
                get do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present profile.boxes, :with => Entities::Box
                end
              end
            end

          end

        end
      end

    end
  end
end
