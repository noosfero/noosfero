module API
  module Entities
    class Article < Grape::Entity
      expose :id, :name, :body, :created_at
#      expose :is_admin?, as: :is_admin

#      expose :avatar_url do |user, options|
#        if user.avatar.present?
#          user.avatar.url
#        end
#      end
    end

    class Comment < Grape::Entity
      expose :author_id, :body, :title, :created_at
    end

    class User < Grape::Entity
      expose :login
    end

    class UserLogin < User
      expose :private_token
    end

  end
end
