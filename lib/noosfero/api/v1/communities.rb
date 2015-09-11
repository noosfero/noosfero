module Noosfero
  module API
    module V1
      class Communities < Grape::API
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
            communities = select_filtered_collection_of(environment, 'communities', params)
            communities = communities.visible_for_person(current_person)
            communities = communities.by_location(params) # Must be the last. May return Exception obj.
            present communities, :with => Entities::Community
          end


          # Example Request:
          #  POST api/v1/communties?private_token=234298743290432&community[name]=some_name
          post do
            params[:community] ||= {}
            begin
              community = Community.create_after_moderation(current_person, params[:community].merge({:environment => environment}))
            rescue
              community = Community.new(params[:community])
            end

            if !community.save
              render_api_errors!(community.errors.full_messages)
            end

            present community, :with => Entities::Community
          end

          get ':id' do
            community = environment.communities.visible_for_person(current_person).find_by_id(params[:id])
            present community, :with => Entities::Community
          end

        end

        resource :people do

          segment '/:person_id' do

            resource :communities do

              get do
                person = environment.people.find(params[:person_id])
                communities = select_filtered_collection_of(person, 'communities', params)
                communities = communities.visible
                present communities, :with => Entities::Community
              end

            end

          end

        end

      end
    end
  end
end
