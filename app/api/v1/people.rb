module Api
  module V1
    class People < Grape::API

      MAX_PER_PAGE = 50

      desc 'API Root'

      resource :people do
        paginate max_per_page: MAX_PER_PAGE

        # -- A note about privacy --
        # We wold find people by location, but we must test if the related
        # fields are public. We can't do it now, with SQL, while the location
        # data and the fields_privacy are a serialized settings.
        # We must build a new table for profile data, where we can set meta-data
        # like:
        # | id | profile_id | key  | value    | privacy_level | source    |
        # |  1 |         99 | city | Salvador | friends       | user      |
        # |  2 |         99 | lng  |  -38.521 | me only       | automatic |

        # Collect people from environment
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /people?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /people?reference_id=10&limit=10&oldest

        desc "Find environment's people"
        get do
          people = select_filtered_collection_of(environment, 'people', params)
          people = people.visible
          present_partial people, :with => Entities::Person, :current_person => current_person
        end

        desc "Return the logged user information"
        get "/me" do
          authenticate!
          present_partial current_person, :with => Entities::Person, :current_person => current_person
        end

        desc "Return the person information"
        get ':id' do
          person = environment.people.visible.find_by(id: params[:id])
          return not_found! if person.blank?
          present_partial person, :with => Entities::Person, :current_person => current_person
        end

        desc "Update person information"
        post ':id' do
          authenticate!
          return forbidden! if current_person.id.to_s != params[:id]
          current_person.update_attributes!(asset_with_image(params[:person]))
          present_partial current_person, :with => Entities::Person, :current_person => current_person
        end

        #  POST api/v1/people?person[login]=some_login&person[password]=some_password&person[name]=Jack
        #  for each custom field for person, add &person[field_name]=field_value to the request
        desc "Create person"
        post do
          authenticate!
          user_data = {}
          user_data[:login] = params[:person].delete(:login) || params[:person][:identifier]
          user_data[:email] = params[:person].delete(:email)
          user_data[:password] = params[:person].delete(:password)
          user_data[:password_confirmation] = params[:person].delete(:password_confirmation)

          params[:person][:custom_values]={}
          params[:person].keys.each do |key|
            params[:person][:custom_values][key]=params[:person].delete(key) if Person.custom_fields(environment).any?{|cf| cf.name==key}
          end

          user = User.build(user_data, asset_with_image(params[:person]), environment)

          begin
            user.signup!
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(user.errors)
          end

          present_partial user.person, :with => Entities::Person, :current_person => user.person
        end

        desc "Return the person friends"
        get ':id/friends' do
          person = environment.people.visible.find_by(id: params[:id])
          return not_found! if person.blank?
          friends = select_filtered_collection_of(person, person.friends.visible, params)
          present_partial friends, :with => Entities::Person, :current_person => current_person
        end

        desc "Return the person friend by id"
        get ':id/friends/:friend_id' do
          person = environment.people.visible.find_by(id: params[:id])
          friend = person.friends.visible.find_by(id: params[:friend_id])
          return not_found! if friend.blank?
          present(friend, :with => Entities::Person, :current_person => current_person)
        end

        desc "Return the status of frendship request"
        get ':id/friendship' do
          person = environment.people.visible.find_by(id: params[:id])
          friend = environment.people.visible.find_by(id: params[:friend_id])
          friend ||= environment.people.visible.find_by(identifier: params[:identifier])

          return not_found! if friend.blank?

          output = {:success => true}
          if person.already_request_friendship?(friend)
            output[:message] = _('You already request a friendship solicitation to %s.') % person.name
            output[:code] = Api::Status::Friendship::WAITING_FOR_APPROVAL
          elsif person.is_a_friend?(friend)
            output[:message] = _("You already a %s's friend") % person.name
            output[:code] = Api::Status::Friendship::FRIEND
          else
            output[:message] = _("You are not a %s's friend and you did not made a friendship request.")
            output[:code] = Api::Status::Friendship::NOT_FRIEND
          end
          present output, :with => Entities::Response
        end

        desc "Add a new friend"
        post ':id/friends' do
          authenticate!
          person = environment.people.visible.find_by(id: params[:id])
          return not_found! if person.blank?
          return bad_request!(('You are already a friend of %s.').html_safe % person.name) if current_person.memberships.include?(person)
          add_friend = AddFriend.new(:person => current_person, :friend => person)
          begin
            add_friend.save!
            present({ message: 'WAITING_APPROVAL' })
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(add_friend.errors)
          end
        end

        desc "Remove a friend"
        delete ':id/friends' do
          authenticate!
          person = environment.people.visible.find_by(id: params[:id])
          return not_found! if person.blank?
          begin
            current_person.remove_friend(person);
            present({ message: 'Friend successfuly removed' })
          rescue ActiveRecord::RecordInvalid
            bad_request!
          end
        end

        desc "Return the person permissions on other profiles"
        get ":id/permissions" do
          authenticate!
          person = environment.people.find(params[:id])
          return not_found! if person.blank?
          return forbidden! unless current_person == person || environment.admins.include?(current_person)

          output = {}
          person.role_assignments.map do |role_assigment|
            if role_assigment.resource.respond_to?(:identifier)
              output[role_assigment.resource.identifier] = role_assigment.role.permissions
            end
          end
          present output
        end
      end

      resource :profiles do
        segment '/:id' do
          resource :members do
            paginate max_per_page: MAX_PER_PAGE
            get do
              profile = environment.profiles.find_by id: params[:id]
              members = select_filtered_collection_of(profile, 'members', params)
              present_partial members, :with => Entities::Person, :current_person => current_person
            end

            post do
              authenticate!
              profile = environment.profiles.find_by id: params[:id]
              profile.add_member(current_person) rescue forbidden!
              {pending: !current_person.is_member_of?(profile)}
            end

            delete do
              authenticate!
              profile = environment.profiles.find_by id: params[:id]
              profile.remove_member(current_person)
              present_partial current_person, :with => Entities::Person, :current_person => current_person
            end
          end
        end
      end

      resource :environments do
        paginate max_per_page: MAX_PER_PAGE

        # -- A note about privacy --
        # We wold find people by location, but we must test if the related
        # fields are public. We can't do it now, with SQL, while the location
        # data and the fields_privacy are a serialized settings.
        # We must build a new table for profile data, where we can set meta-data
        # like:
        # | id | profile_id | key  | value    | privacy_level | source    |
        # |  1 |         99 | city | Salvador | friends       | user      |
        # |  2 |         99 | lng  |  -38.521 | me only       | automatic |

        # Collect people from environment
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /environments/1/people?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /environments/people?reference_id=10&limit=10&oldest

        resource ':id/people' do
          get do
            local_environment = Environment.find(params[:id])
            people = select_filtered_collection_of(local_environment, 'people', params)
            people = people.visible
            present_partial people, :with => Entities::Person, :current_person => current_person
          end
        end


        resource :people do
          desc "Find environment's people"
          get do
            people = select_filtered_collection_of(environment, 'people', params)
            people = people.visible
            present_partial people, :with => Entities::Person, :current_person => current_person
          end
        end
      end
      resource :articles do
        #FIXME see if this is the better place for this endpoint
        desc "Returns the total followers for the article" do
          detail 'Get the followers of a specific article by id'
          failure [[Api::Status::Http::FORBIDDEN, 'Forbidden']]
          named 'ArticleFollowers'
        end
        get ':id/followers' do
          article = find_article(environment.articles, {:id => params[:id]} )
          people = article.person_followers
          present_partial people, :with => Entities::Person, :current_person => current_person
        end
      end
    end
  end
end
