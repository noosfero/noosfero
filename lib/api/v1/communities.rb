module API
  module V1
    class Communities < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :communities do

        # Collect comments from articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /communities?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /communities?reference_id=10&limit=10&oldest
        get do
          communities = select_filtered_collection_of(current_person, 'communities', params)
          present communities, :with => Entities::Community
        end

        #FIXME See only public communities
        get '/all' do
          communities = select_filtered_collection_of(environment, 'communities', params)
          present communities, :with => Entities::Community
        end

        get ':id' do
          community = environment.communities.find(params[:id])
          present community, :with => Entities::Community
        end

      end

    end
  end
end
