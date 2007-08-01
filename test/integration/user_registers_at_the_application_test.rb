require "#{File.dirname(__FILE__)}/../test_helper"

class UserRegistersAtTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :virtual_communities, :profiles

  # Replace this with your real tests.
  def test_successfull_registration
    get '/'
    assert_tag :tag => 'span', :attributes => { :id => 'register_box' }

    get '/account/signup'
    assert_response :success
    
    post '/account/signup', :user => { :login => 'mylogin', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :redirect
    assert_redirected_to '/account'

    # user is logged in right after the registration
    follow_redirect!
    assert_no_tag :tag => 'span', :attributes => { :id => 'login_box' }
    assert_tag :tag => 'span', :attributes => { :id => 'user_links'  }
    assert_tag :tag => 'span', :attributes => { :id => 'logout_box'  }
  end

  def test_trying_an_existing_login_name

    assert User.find_by_login('ze') # just to make sure that 'ze' already exists

    get '/'
    assert_tag :tag => 'span', :attributes => { :id => 'register_box' }

    get '/account/signup'
    assert_response :success
    
    post '/account/signup', :user => { :login => 'ze', :password => 'mypassword', :password_confirmation => 'mypassword', :email => 'mylogin@example.com' }
    assert_response :success
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation', :class => 'errorExplanation' }

  end

end
