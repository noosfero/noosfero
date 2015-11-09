require 'test_helper'

class ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    Noosfero::API::API
  end

  def login_api
    @user = User.create!(:login => 'testapi', :password => 'testapi', :password_confirmation => 'testapi', :email => 'test@test.org', :environment => Environment.default)
    @user.activate
    @person = @user.person

    post "/api/v1/login?login=testapi&password=testapi"
    json = JSON.parse(last_response.body)
    @private_token = json["private_token"]
    @params = {:private_token => @private_token}
  end
  attr_accessor :private_token, :user, :person, :params

  private

  def json_response_ids(kind)
    json = JSON.parse(last_response.body)
    json[kind.to_s].map {|c| c['id']}
  end

end
