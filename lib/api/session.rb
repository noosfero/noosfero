module API

#   require 'api/validations/uniqueness'

  # Users API
  class Session < Grape::API
#params do
#  requires :login, :uniqueness => true
#end

    # Login to get token
    #
    # Parameters:
    #   login (*required) - user login or email
    #   password (required) - user password
    #
    # Example Request:
    #  POST /session
    get "/login" do
#    post "/session" do
environment = nil #FIXME load the correct environment create a method in helper
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
      #   name                              - Name
      # Example Request:
      #   POST /users
#      post do
      get "register" do
        required_attributes! [:email, :login, :password]
        attrs = attributes_for_keys [:email, :login, :password]
        attrs[:password_confirmation] = attrs[:password]
        user = User.new(attrs)
begin
        if user.save
          present user, :with => Entities::User
        else
          not_found!
        end
rescue
#          not_found!
#FIXME See  why notfound is not working
{}
end
#        user
      end



  end
end
