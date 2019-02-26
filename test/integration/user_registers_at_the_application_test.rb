require_relative "../test_helper"

class UserRegistersAtTheApplicationTest < ActionDispatch::IntegrationTest
  fixtures :users, :environments, :profiles

  def test_successful_registration
    get '/'
    assert_can_login
    assert_can_signup

    get '/account/signup'

    assert_response :success

    post '/account/signup', params: {user: { login: 'mylogin',
                                             password: 'mypassword',
                                             password_confirmation: 'mypassword',
                                             email: 'mylogin@example.com' }
                                    }
    assert_response :redirect

    assert_tag :tag => 'a', :content => 'redirected'
  end

  def test_trying_an_existing_login_name
    env = Environment.default
    env.save!

    assert User.find_by(login: 'ze') # just to make sure that 'ze' already exists

    get '/'
    assert_can_login
    assert_can_signup

    get '/account/signup'

    assert_response :success

    post '/account/signup', params: { user: { login: 'ze',
                                             password: 'mypassword',
                                             password_confirmation: 'mypassword',
                                             email: 'mylogin@example.com' }
                                    }
    assert_response :success
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation', :class => 'errorExplanation' }

  end

end
