module Api
  module V1

    class Settings < Grape::API

      kinds = %w[profile environment]
      kinds.each do |kind|
        resource kind.pluralize.to_sym do
          segment "/:#{kind}_id" do
            resource :settings do

              get do
                  owner = kind=='environment' ? Environment.find(params["#{kind}_id"]) : environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_partial settings(owner), :with => Entities::Setting, current_person: current_person
              end

              get 'available_blocks' do
                  owner = kind=='environment' ? Environment.find(params["#{kind}_id"]) : environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_partial settings(owner)[:available_blocks], :with => Entities::BlockDefinition, current_person: current_person
              end

            end
          end
        end
      end

    end
  end
end
