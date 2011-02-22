require "#{File.dirname(__FILE__)}/../test_helper"

class LoginToTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_unauthenticated_user_tries_to_access_his_control_panel
    Environment.any_instance.stubs(:enable_ssl).returns(false) # ignore SSL for this test 

    get '/myprofile/ze'
    assert_redirected_to '/account/login'

    post '/account/login', :user => { :login => 'ze', :password => "test" }

    assert_redirected_to '/myprofile/ze'
  end

end
