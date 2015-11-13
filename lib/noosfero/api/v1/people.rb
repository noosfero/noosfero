module Noosfero
  module API
    module V1
      class People < Grape::API
        before { authenticate! }

        desc 'API Root'

        resource :people do

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
            people = people.visible_for_person(current_person)
            present people, :with => Entities::Person
          end

          desc "Return the logged user information"
          get "/me" do
            present current_person, :with => Entities::Person
          end

          desc "Return the person information"
          get ':id' do
            person = environment.people.visible_for_person(current_person).find_by_id(params[:id])
            return not_found! if person.blank?
            present person, :with => Entities::Person
          end

          desc "Update person information"
          post ':id' do
            return forbidden! if current_person.id.to_s != params[:id]
            current_person.update_attributes!(params[:person])
            present current_person, :with => Entities::Person
          end

          # Example Request:
          #  POST api/v1/people?person[login]=some_login&person[password]=some_password&person[name]=Jack
          desc "Create person"
          post do
            user_data = {}
            user_data[:login] = params[:person].delete(:login) || params[:person][:identifier]
            user_data[:email] = params[:person].delete(:email)
            user_data[:password] = params[:person].delete(:password)
            user_data[:password_confirmation] = params[:person].delete(:password_confirmation)
            user = User.build(user_data, params[:person], environment)
            begin
              user.signup!
            rescue ActiveRecord::RecordInvalid
              render_api_errors!(user.errors.full_messages)
            end

            present user.person, :with => Entities::Person
          end

          desc "Return the person friends"
          get ':id/friends' do
            person = environment.people.visible_for_person(current_person).find_by_id(params[:id])
            return not_found! if person.blank?
            friends = person.friends.visible
            present friends, :with => Entities::Person
          end

          desc "Return the person permissions on other profiles"
          get ":id/permissions" do
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
      end
    end
  end
end
