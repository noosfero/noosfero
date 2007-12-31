require "#{File.dirname(__FILE__)}/../test_helper"

class UserRegistersAtTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_successfull_registration
    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/account/login' }

    get '/account/login'
    assert_tag :tag => 'a', :attributes => { :href => '/account/signup'}

    get '/account/signup'
    assert_response :success
    
    post '/account/signup', :user => { :login => 'mylogin', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :redirect
    assert_redirected_to '/mylogin'

    # user is logged in right after the registration
    follow_redirect!
    assert_no_tag :tag => 'a', :attributes => { :href => '/account/login' }
    assert_tag :tag => 'a', :attributes => { :href => '/account/logout'  }
  end

  def test_trying_an_existing_login_name

    assert User.find_by_login('ze') # just to make sure that 'ze' already exists

    get '/'
    assert_tag :tag => 'a', :attributes => { :href => '/account/login'}

    get '/account/login'
    assert_tag :tag => 'a', :attributes => { :href => '/account/signup'}

    get '/account/signup'
    assert_response :success
    
    post '/account/signup', :user => { :login => 'ze', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :success
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation', :class => 'errorExplanation' }

  end

end
