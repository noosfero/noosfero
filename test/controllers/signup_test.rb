require_relative "../test_helper"

class SignupTest < ActionDispatch::IntegrationTest

  all_fixtures

  def setup
    ActionDispatch::Integration::Session.any_instance.stubs(:https?).returns(true)
  end

  should 'render terms acceptance field' do
    Environment.default.update(terms_of_use: 'You agree to not be annoying.')
    get '/account/signup'
    assert_tag :tag => 'input', :attributes => { :name => 'user[terms_accepted]' }
  end

  should 'not create user that did not accepet the temrs' do
    @env = Environment.default
    @env.terms_of_use = 'You agree to not be annoying.'
    @env.save!

    assert_no_difference 'User.count' do
      post '/account/signup', params: {user: { login: 'shouldaccepterms',
                                               password: 'test',
                                               password_confirmation: 'test',
                                               email: 'shouldaccepterms@example.com'
                                             }
                                      }
      assert_response :success
    end
  end

  should 'create user that accepted the terms' do
    @env = Environment.default
    @env.terms_of_use = 'You agree to not be annoying.'
    @env.save!

    assert_difference 'User.count' do
      post '/account/signup', params: { user: { login: 'shouldaccepterms',
                                                password: 'test',
                                                password_confirmation: 'test',
                                                email: 'shouldaccepterms@example.com',
                                                terms_accepted: '1'
                                              },
                                        profile_data: person_data
                                      }
      user = User.last
      assert_redirected_to action: :activate,
                           activation_token: user.activation_code,
                           return_to: { controller: :home, action: :welcome, template_id: nil }
    end

    assert_difference("ActionMailer::Base.deliveries.count", 1) do
      process_delayed_job_queue
    end
  end
end
