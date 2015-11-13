module Noosfero
  module API
    module Entities

      Entity.format_with :timestamp do |date|
        date.strftime('%Y/%m/%d %H:%M:%S') if date
      end

      PERMISSIONS = {
        :admin => 0,
        :self  => 10,
        :friend => 20,
        :logged_user => 30,
        :anonymous => 40
      }

      def self.can_display? profile, options, field, permission = :friend
        return true if profile.public_fields.include?(field)
        current_person = options[:current_person]

        current_permission = if current_person.present?
          if current_person.is_admin?
            :admin
          elsif current_person == profile
            :self
          elsif current_person.friends.include?(profile)
            :friend
          else
            :logged_user
          end
        else
          :anonymous
        end

        PERMISSIONS[current_permission] <= PERMISSIONS[permission]
      end

      class Image < Entity
        root 'images', 'image'

        expose  :url do |image, options|
          image.public_filename
        end

        expose  :icon_url do |image, options|
          image.public_filename(:icon)
        end

        expose  :minor_url do |image, options|
          image.public_filename(:minor)
        end

        expose  :portrait_url do |image, options|
          image.public_filename(:portrait)
        end

        expose  :thumb_url do |image, options|
          image.public_filename(:thumb)
        end
      end

      class CategoryBase < Entity
        root 'categories', 'category'
        expose :name, :id, :slug
      end

      class Category < CategoryBase
        root 'categories', 'category'
        expose :full_name do |category, options|
          category.full_name
        end
        expose :parent, :using => CategoryBase, if: { parent: true }
        expose :children, :using => CategoryBase, if: { children: true }
        expose :image, :using => Image
        expose :display_color
      end

      class Region < Category
        root 'regions', 'region'
        expose :parent_id
      end

      class Profile < Entity
        expose :identifier, :name, :id
        expose :created_at, :format_with => :timestamp
        expose :updated_at, :format_with => :timestamp
        expose :image, :using => Image
        expose :region, :using => Region
      end

      class UserBasic < Entity
        expose :id
        expose :login
      end

      class Person < Profile
        root 'people', 'person'
        expose :user, :using => UserBasic, documentation: {type: 'User', desc: 'The user data of a person' }
      end

      class Enterprise < Profile
        root 'enterprises', 'enterprise'
      end

      class Community < Profile
        root 'communities', 'community'
        expose :description
        expose :admins do |community, options|
          community.admins.map{|admin| {"name"=>admin.name, "id"=>admin.id}}
        end
        expose :categories, :using => Category
        expose :members, :using => Person
      end

      class ArticleBase < Entity
        root 'articles', 'article'
        expose :id
        expose :body
        expose :abstract, documentation: {type: 'String', desc: 'Teaser of the body'}
        expose :created_at, :format_with => :timestamp
        expose :updated_at, :format_with => :timestamp
        expose :title, :documentation => {:type => "String", :desc => "Title of the article"}
        expose :created_by, :as => :author, :using => Profile, :documentation => {type: 'Profile', desc: 'The profile author that create the article'}
        expose :profile, :using => Profile, :documentation => {type: 'Profile', desc: 'The profile associated with the article'}
        expose :categories, :using => Category
        expose :image, :using => Image
        expose :votes_for
        expose :votes_against
        expose :setting
        expose :position
        expose :hits
        expose :start_date
        expose :end_date, :documentation => {type: 'DateTime', desc: 'The date of finish of the article'}
        expose :tag_list
        expose :children_count
        expose :slug, :documentation => {:type => "String", :desc => "Trimmed and parsed name of a article"}
        expose :path
      end

      class Article < ArticleBase
        root 'articles', 'article'
        expose :parent, :using => ArticleBase
        expose :children, :using => ArticleBase
      end

      class Comment < Entity
        root 'comments', 'comment'
        expose :body, :title, :id
        expose :created_at, :format_with => :timestamp
        expose :author, :using => Profile
      end

      class User < Entity
        root 'users', 'user'

        attrs = [:id,:login,:email,:activated?]
        aliases = {:activated? => :activated}

        attrs.each do |attribute|
          name = aliases.has_key?(attribute) ? aliases[attribute] : attribute
          expose attribute, :as => name, :if => lambda{|user,options| Entities.can_display?(user.person, options, attribute)}
        end

        expose :person, :using => Person
        expose :permissions, :if => lambda{|user,options| Entities.can_display?(user.person, options, :permissions, :self)} do |user, options|
          output = {}
          user.person.role_assignments.map do |role_assigment|
            if role_assigment.resource.respond_to?(:identifier) && !role_assigment.role.nil?
              output[role_assigment.resource.identifier] = role_assigment.role.permissions
            end
          end
          output
        end
      end

      class UserLogin < User
        root 'users', 'user'
        expose :private_token, documentation: {type: 'String', desc: 'A valid authentication code for post/delete api actions'}
      end

      class Task < Entity
        root 'tasks', 'task'
        expose :id
        expose :type
      end

      class Environment < Entity
        expose :name
      end

      class Tag < Entity
        root 'tags', 'tag'
        expose :name
      end


    end
  end
end
