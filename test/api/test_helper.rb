require 'test_helper'

class ActiveSupport::TestCase

  include Rack::Test::Methods

  USER_PASSWORD = "testapi"
  USER_LOGIN = "testapi"

  def app
    Noosfero::API::API
  end

  def create_and_activate_user
    @environment = Environment.default
    @user = User.create!(:login => USER_LOGIN, :password => USER_PASSWORD, :password_confirmation => USER_PASSWORD, :email => 'test@test.org', :environment => @environment)
    @user.activate
    @person = @user.person
    @params = {}
  end

  def login_api
    post "/api/v1/login?login=#{USER_LOGIN}&password=#{USER_PASSWORD}"
    json = JSON.parse(last_response.body)
    @private_token = json["private_token"]
    unless @private_token
      @user.generate_private_token!
      @private_token = @user.private_token
    end

    @params[:private_token] = @private_token
  end

  attr_accessor :private_token, :user, :person, :params, :environment

  private

  def json_response_ids(kind)
    json = JSON.parse(last_response.body)
    json[kind.to_s].map {|c| c['id']}
  end

end
