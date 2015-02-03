require_relative "../test_helper"

class LoginToTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_unauthenticated_user_tries_to_access_his_control_panel
    get '/myprofile/ze'
    assert_redirected_to '/account/login'

    post '/account/login', :user => { :login => 'ze', :password => "test" }

    assert_redirected_to '/myprofile/ze'
  end

end
