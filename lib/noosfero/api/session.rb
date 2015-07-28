require "uri"

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
        @current_user = user
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

        #Commented for stress tests

        # remote_ip = (request.respond_to?(:remote_ip) && request.remote_ip) || (env && env['REMOTE_ADDR'])
        # private_key = API.NOOSFERO_CONF['api_recaptcha_private_key']
        # api_recaptcha_verify_uri = API.NOOSFERO_CONF['api_recaptcha_verify_uri']
        # captcha_result = verify_recaptcha_v2(remote_ip, params['g-recaptcha-response'], private_key, api_recaptcha_verify_uri)
        user = User.new(attrs)
#        if captcha_result["success"] and user.save
        if user.save
          user.activate
          user.generate_private_token!
          present user, :with => Entities::UserLogin
        else
          message = user.errors.to_json
          render_api_error!(message, 400)
        end
      end
    end
  end
end
