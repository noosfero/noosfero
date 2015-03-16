require File.dirname(__FILE__) + '/test_helper'

class APITest < ActiveSupport::TestCase

  include API::APIHelpers

#  def setup
#    login_api
#  end

  should 'get the current user' do
    user = create_user('someuser')
#    params = {:private_token => user.private_token}
#    post "/api/v1/login?#{params.to_query}"
#    json = JSON.parse(last_response.body)
    User.expects(:find_by_private_token).returns(user)
    assert_equal user, current_user
#   
#    assert !json["private_token"].blank?
  end

#  should 'return 401 when login fails' do
#    user.destroy
#    params = {:login => "testapi", :password => "testapi"}
#    post "/api/v1/login?#{params.to_query}"
#    assert_equal 401, last_response.status
#  end
#
#  should 'register a user' do
#    params = {:login => "newuserapi", :password => "newuserapi", :email => "newuserapi@email.com" }
#    post "/api/v1/register?#{params.to_query}"
#    assert_equal 201, last_response.status
#  end
#
#  should 'do not register a user without email' do
#    params = {:login => "newuserapi", :password => "newuserapi", :email => nil }
#    post "/api/v1/register?#{params.to_query}"
#    assert_equal 400, last_response.status
#  end
#
#  should 'do not register a duplicated user' do
#    params = {:login => "newuserapi", :password => "newuserapi", :email => "newuserapi@email.com" }
#    post "/api/v1/register?#{params.to_query}"
#    post "/api/v1/register?#{params.to_query}"
#    assert_equal 400, last_response.status
#  end
#
end
