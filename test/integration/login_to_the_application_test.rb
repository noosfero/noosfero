require "#{File.dirname(__FILE__)}/../test_helper"

class LoginToTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_anonymous_user_logins_to_application
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/account/login' }
    assert_no_tag :tag => 'a', :attributes => { :href => '/account/logout'  }

    get '/account/login'
    assert_response :success

    login('ze', 'test')
    assert_no_tag :tag => 'a', :attributes => { :href => '/account/login' }
    assert_tag :tag => 'a', :attributes => { :href => '/account/logout'  }

  end

end
