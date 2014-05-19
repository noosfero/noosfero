module API
  module V1
    class People < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :people do

        # Collect comments from articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /people?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /people?reference_id=10&limit=10&oldest
        get do
          people = select_filtered_collection_of(environment, 'people', params)
          present people, :with => Entities::Person
        end

        desc "Return the person information" 
        get '/:id' do
          present environment.people.find(params[:id]), :with => Entities::Person
        end

      end
   
    end
  end
end
