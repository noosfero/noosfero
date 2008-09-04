require "#{File.dirname(__FILE__)}/../test_helper"

class SignupTest < ActionController::IntegrationTest
  all_fixtures

  def setup
    ActionController::Integration::Session.any_instance.stubs(:https?).returns(true)
  end

  def test_should_require_acceptance_of_terms_for_signup
    Environment.default.update_attributes(:terms_of_use => 'You agree to not be annoying.')

    count = User.count

    get '/account/signup'
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'user[terms_accepted]' }

    post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com'  }
    assert_response :success
    assert_template 'signup'
    assert_equal count, User.count

    post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com', :terms_accepted => '1' }
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal count + 1, User.count

  end

end
