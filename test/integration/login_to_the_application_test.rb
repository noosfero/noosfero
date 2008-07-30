require "#{File.dirname(__FILE__)}/../test_helper"

class LoginToTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_anonymous_user_logins_to_application
    get '/'

    assert_can_login
    assert_cannot_logout

    get '/account/login_popup'
    assert_response :success

    login('ze', 'test')
    assert_cannot_login
    assert_can_logout

  end

end
