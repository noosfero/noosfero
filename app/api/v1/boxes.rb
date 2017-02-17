module Api
  module V1

    class Boxes < Grape::API

      kinds = %w[profile community person enterprise]
      kinds.each do |kind|

        resource kind.pluralize.to_sym do

          segment "/:#{kind}_id" do
            resource :boxes do
              get do
                profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                return forbidden! unless profile.display_info_to?(current_person)
                present_partial profile.boxes, with: Entities::Box, current_person: current_person
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
                present_partial env.boxes, with: Entities::Box, current_person: current_person
              end
            end
          end
        end
      end
    end

  end
end
