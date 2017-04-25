module Api
  module V1
    class Communities < Grape::API

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
          communities = profiles_for_person(communities, current_person)
          communities = communities.by_location(params) # Must be the last. May return Exception obj
          present_partial communities, :with => Entities::Community, :current_person => current_person, :params => params
        end


        # Example Request:
        #  POST api/v1/communties?private_token=234298743290432&community[name]=some_name
        #  for each custom field for community, add &community[field_name]=field_value to the request
        post do
          authenticate!
          params[:community] ||= {}

          params[:community][:custom_values]={}
          params[:community].keys.each do |key|
            params[:community][:custom_values][key]=params[:community].delete(key) if Community.custom_fields(environment).any?{|cf| cf.name==key}
          end

          begin
            community = Community.create_after_moderation(current_person, params[:community].merge({:environment => environment}))
          rescue
            community = Community.new(params[:community])
          end

          if !community.save
            render_model_errors!(community.errors)
          end

          present_partial community, :with => Entities::Community, :current_person => current_person
        end

        get ':id' do
          community = profiles_for_person(environment.communities, current_person).find_by_id(params[:id])
          not_found! unless community.present?
          present_partial community, :with => Entities::Community, :current_person => current_person, :params => params
        end



        desc 'Send invitations of users to community' do
          detail 'The invitation must be provided by a user logged user with permission'
          params Entities::Response.documentation
          success Entities::Response
          named 'CommunityInvite'
        end
        post ':id/invite' do
          authenticate!
          community = profiles_for_person(environment.communities, current_person).find_by_id(params[:id])
          not_found! unless community.present?
          forbidden! unless community.allow_invitation_from?(current_person)
          Delayed::Job.enqueue InvitationJob.new(current_person.id, params[:contacts], '', community.id, nil, I18n.locale)
          msg = {
            :success => true,
            :message => _('Your invitation was registered. The community administrators are reviewing your solicitation.'),
            :code => Api::Status::INVITATION_SENT_TO_BE_PROCESSED 
          }

          present msg, :with => Entities::Response
        end

      end

      resource :people do

        segment '/:person_id' do

          resource :communities do

            get do
              person = environment.people.find(params[:person_id])

              not_found! if person.blank?
              forbidden! if !person.display_info_to?(current_person)

              communities = select_filtered_collection_of(person, 'communities', params)
              communities = communities.visible
              present_partial communities, :with => Entities::Community, :current_person => current_person
            end

          end

        end

      end

    end
  end
end
