module API
  module V1
  class Users < Grape::API
 
    before { authenticate! }

    resource :users do

      #FIXME make the pagination
      #FIXME put it on environment context
#      get do
#        Users.all
#      end
 
      get ":id" do
        present Article.find(params[:id]).comments.find(params[:comment_id]), :with => Entities::User
      end

      # Create user.
      #
      # Parameters:
      #   email (required)                  - Email
      #   password (required)               - Password
      #   name                              - Name
      # Example Request:
      #   POST /users
#      post do
      get do
#        authenticated_as_admin!
        required_attributes! [:email, :login, :password]
        attrs = attributes_for_keys [:email, :login, :password]
        user = User.new(attrs)
        if user.save
          present user, :with => Entities::User
        else
          not_found!
        end
      end
    end
 
  end
  end
end
