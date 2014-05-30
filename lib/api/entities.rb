module API
  module Entities

    class Image < Grape::Entity
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

    class Profile < Grape::Entity
      expose :identifier, :name, :created_at, :id
      expose :image, :using => Image
    end

    class Person < Profile;end;
    class Enterprise < Profile;end;
    class Community < Profile
      root 'communities', 'community'
      expose :description
    end

    class Category < Grape::Entity
      root 'categories', 'category'
      expose :name, :id, :slug
      expose :image, :using => Image
    end


    class Article < Grape::Entity
      root 'articles', 'article'
      expose :id, :body, :created_at
      expose :title, :documentation => {:type => "String", :desc => "Title of the article"}
      expose :author, :using => Profile
      expose :profile, :using => Profile
      expose :categories, :using => Category
    end

    class Comment < Grape::Entity
      root 'comments', 'comment'
      expose :body, :title, :created_at, :id

      expose :author, :using => Profile
    end


    class User < Grape::Entity
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
