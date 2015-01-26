require_relative "../test_helper"

class UserRegistersAtTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_successfull_registration
    get '/'
    assert_can_login
    assert_can_signup

    get '/account/signup'

    assert_response :success
    
    post '/account/signup', :user => { :login => 'mylogin', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => /^\/account\/login/ }
  end

  def test_trying_an_existing_login_name
    env = Environment.default
    env.min_signup_delay = 0
    env.save!

    assert User.find_by_login('ze') # just to make sure that 'ze' already exists

    get '/'
    assert_can_login
    assert_can_signup

    get '/account/signup'

    assert_response :success
    
    post '/account/signup', :user => { :login => 'ze', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :success
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation', :class => 'errorExplanation' }

  end

end
