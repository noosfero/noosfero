module Noosfero
  module API
  
    class Session < Grape::API
  
      # Login to get token
      #
      # Parameters:
      #   login (*required) - user login or email
      #   password (required) - user password
      #
      # Example Request:
      #  POST http://localhost:3000/api/v1/login?login=adminuser&password=admin
      post "/login" do
        user ||= User.authenticate(params[:login], params[:password], environment)
  
        return unauthorized! unless user
        user.generate_private_token!
        present user, :with => Entities::UserLogin
      end
  
      # Create user.
      #
      # Parameters:
      #   email (required)                  - Email
      #   password (required)               - Password
      #   login                             - login
      # Example Request:
      #   POST /register?email=some@mail.com&password=pas&login=some
      params do
        requires :email, type: String, desc: _("Email")
        requires :login, type: String, desc: _("Login")
        requires :password, type: String, desc: _("Password")
      end
      post "/register" do
        unique_attributes! User, [:email, :login]
        attrs = attributes_for_keys [:email, :login, :password]
        attrs[:password_confirmation] = attrs[:password]
        user = User.new(attrs)
        if user.save
          user.activate
          present user, :with => Entities::User
        else
          something_wrong!
        end
      end
  
    end
  end
end
