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

        resource :environments do
          [ '/default', '/context', ':environment_id' ].each do |route|
            segment route do
              resource :boxes do
                get do
                  if (route.match(/default/))
                    env = Environment.default
                  elsif (route.match(/context/))
                    env = environment
                  else
                    env = Environment.find(params[:environment_id])
                  end
                  present env.boxes, :with => Entities::Box
                end
              end
            end
          end
        end
      end

    end
  end
end
