module Api
  module V1
    class Enterprises < Grape::API::Instance
      resource :enterprises do
        # Collect enterprises from environment
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #   georef params    - read `Profile.by_location` for more information.
        #
        # Example Request:
        #  GET /enterprises?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /enterprises?reference_id=10&limit=10&oldest
        get do
          enterprises = select_filtered_collection_of(environment, "enterprises", params)
          enterprises = enterprises.visible
          enterprises = enterprises.by_location(params) # Must be the last. May return Exception obj.
          present enterprises, with: Entities::Enterprise, current_person: current_person, params: params
        end

        desc "Return one enterprise by id"
        get ":id" do
          enterprise = environment.enterprises.visible.find_by(id: params[:id])
          not_found! unless enterprise.present?
          present enterprise, with: Entities::Enterprise, current_person: current_person, params: params
        end
      end

      resource :people do
        segment "/:person_id" do
          resource :enterprises do
            get do
              person = environment.people.find(params[:person_id])
              enterprises = select_filtered_collection_of(person, "enterprises", params)
              enterprises = enterprises.visible.by_location(params)
              present enterprises, with: Entities::Enterprise, current_person: current_person, params: params
            end
          end
        end
      end
    end
  end
end
