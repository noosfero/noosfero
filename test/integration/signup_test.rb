require_relative "../test_helper"

class SignupTest < ActionDispatch::IntegrationTest

  all_fixtures

  def setup
    ActionDispatch::Integration::Session.any_instance.stubs(:https?).returns(true)
  end

  def test_signup_form_submission_must_be_blocked_for_fast_bots
    assert_no_difference 'User.count' do
      registering_with_bot_test 5, 1
    end
    assert_template 'signup'
    assert_match /robot/, @response.body
  end

  def test_signup_form_submission_must_not_block_after_min_signup_delay
    assert_difference 'User.count', 1 do
      registering_with_bot_test 1, 2
    end
  end

  def test_should_require_acceptance_of_terms_for_signup
    env = Environment.default
    env.update(:terms_of_use => 'You agree to not be annoying.')
    env.min_signup_delay = 0
    env.save!

    count = User.count
    mail_count = ActionMailer::Base.deliveries.count

    get '/account/signup'
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => 'user[terms_accepted]' }

    post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com'  }
    assert_response :success
    assert_template 'signup'
    assert_equal count, User.count
    assert_equal mail_count, ActionMailer::Base.deliveries.count

    post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com', :terms_accepted => '1' }, :profile_data => person_data
    assert_redirected_to controller: 'home', action: 'welcome'

    assert_equal count + 1, User.count
    assert_equal mail_count + 1, ActionMailer::Base.deliveries.count

  end

  private

  def registering_with_bot_test(min_signup_delay, sleep_secs)
    env = Environment.default
    env.min_signup_delay = min_signup_delay
    env.save!
    get '/account/signup'
    assert_response :success
    get '/account/signup_time'
    assert_response :success
    data = ActiveSupport::JSON.decode @response.body
    sleep sleep_secs
    post '/account/signup', :user => { :login => 'someone', :password => 'test', :password_confirmation => 'test', :email => 'someone@example.com' }, :signup_time_key => data['key']
    sleep_secs > min_signup_delay ? assert_redirected_to(controller: 'home', action: 'welcome') : assert_response(:success)
  end

end
