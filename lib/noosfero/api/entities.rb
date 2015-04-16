module Noosfero
  module API
    module Entities
  
      Entity.format_with :timestamp do |date|
        date.strftime('%Y/%m/%d %H:%M:%S') if date
      end
  
      class Image < Entity
        root 'images', 'image'
  
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
  
      class Profile < Entity
        expose :identifier, :name, :id
        expose :created_at, :format_with => :timestamp
        expose :image, :using => Image
      end
  
      class Person < Profile
        root 'people', 'person'
      end
      class Enterprise < Profile
        root 'enterprises', 'enterprise'
      end
      class Community < Profile
        root 'communities', 'community'
        expose :description
      end
  
      class Category < Entity
        root 'categories', 'category'
        expose :name, :id, :slug
        expose :image, :using => Image
      end
  
      class ArticleChild < Entity
        root 'articles', 'article'
        expose :id, :body, :abstract
        expose :created_at, :format_with => :timestamp
        expose :title, :documentation => {:type => "String", :desc => "Title of the article"}
        expose :created_by, :as => :author, :using => Profile
        expose :profile, :using => Profile
        expose :categories, :using => Category
        expose :image, :using => Image
      end

      class Article < Entity
        root 'articles', 'article'
        expose :id, :body, :abstract
        expose :created_at, :format_with => :timestamp
        expose :title, :documentation => {:type => "String", :desc => "Title of the article"}
        expose :created_by, :as => :author, :using => Profile
        expose :profile, :using => Profile
        expose :categories, :using => Category
        # FIXME: create a method that overrides expose and include conditions for return attributes
        expose :parent, :using => Article
        expose :children, :using => ArticleChild
        expose :image, :using => Image
      end

      class Comment < Entity
        root 'comments', 'comment'
        expose :body, :title, :id
        expose :created_at, :format_with => :timestamp
        expose :author, :using => Profile
      end
  
  
      class User < Entity
        root 'users', 'user'
        expose :id
        expose :login
        expose :person, :using => Profile
        expose :permissions do |user, options|
          output = {}
          user.person.role_assignments.map do |role_assigment|
            if role_assigment.resource.respond_to?(:identifier)
              output[role_assigment.resource.identifier] = role_assigment.role.permissions 
            end
          end
          output
        end
      end
  
      class UserLogin < User
        expose :private_token
      end
  
    end
  end
end
