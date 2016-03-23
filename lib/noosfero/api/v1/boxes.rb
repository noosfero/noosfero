module Noosfero
  module API
    module V1

      class Boxes < Grape::API

        kinds = %w[profile community person enterprise environment]
        kinds.each do |kind|

          resource kind.pluralize.to_sym do

            segment "/:#{kind}_id" do
              resource :boxes do
                get do
                  if (kind == "environment")
                    container = Environment.find(params["environment_id"])
                  else
                    container = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  end
                  present container.boxes, :with => Entities::Box
                end
              end
            end

          end

        end
      end

    end
  end
end
