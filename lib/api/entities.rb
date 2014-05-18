module API
  module Entities

    class Image < Grape::Entity

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
      expose :description
    end

    class Category < Grape::Entity
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
#, :if => lambda { |instance, options| raise params.inspect }
# do |instance, options|
#    # examine available environment keys with `p options[:env].keys`
#    options[:user]
#  end

    end

    class Comment < Grape::Entity
      root 'comments', 'comment'
      expose :body, :title, :created_at, :id

      expose :author, :using => Profile
    end


    class User < Grape::Entity
      root 'users', 'user'
      expose :login
      expose :person, :using => Profile
    end

    class UserLogin < User
      expose :private_token
    end

  end
end
