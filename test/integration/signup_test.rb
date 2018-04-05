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
  end

  def test_signup_form_submission_must_not_block_after_min_signup_delay
    assert_difference 'User.count', 1 do
      registering_with_bot_test 1, 2
    end
  end

  should 'render terms acceptance field' do
    Environment.default.update(terms_of_use: 'You agree to not be annoying.')
    get '/account/signup'
    assert_tag :tag => 'input', :attributes => { :name => 'user[terms_accepted]' }
  end

  should 'not create user that did not accepet the temrs' do
    @env = Environment.default
    @env.terms_of_use = 'You agree to not be annoying.'
    @env.min_signup_delay = 0
    @env.save!

    assert_no_difference 'User.count' do
      post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com'  }
      assert_response :success
    end
  end

  should 'create user that accepted the temrs' do
    @env = Environment.default
    @env.terms_of_use = 'You agree to not be annoying.'
    @env.min_signup_delay = 0
    @env.save!

    assert_difference 'User.count' do
      post '/account/signup', :user => { :login => 'shouldaccepterms', :password => 'test', :password_confirmation => 'test', :email => 'shouldaccepterms@example.com', :terms_accepted => '1' }, :profile_data => person_data
      user = User.last
      assert_redirected_to action: :activate,
                           activation_token: user.activation_code,
                           return_to: { controller: :home, action: :welcome, template_id: nil }
    end

    assert_difference 'ActionMailer::Base.deliveries.count' do
      process_delayed_job_queue
    end
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
    if sleep_secs > min_signup_delay
      user = User.last
      assert_redirected_to action: :activate,
                           activation_token: user.activation_code,
                           return_to: { controller: :home, action: :welcome, template_id: nil }
    else
      assert_response(:success)
    end
  end

end
