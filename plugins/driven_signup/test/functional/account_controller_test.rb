require 'test_helper'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    e = Environment.default
    e.enable 'skip_new_user_email_confirmation', true
    disable_signup_bot_check e
  end

  should 'use the parameters' do
    community = create Community, name: 'base', identifier: 'base1'
    subcommunity = create Community, name: 'sub', identifier: 'base11'
    subcommunity.reload

    # simulate DrivenSignupPlugin::AccountController
    session[:driven_signup] = true
    session[:base_organization] = community.identifier
    session[:find_suborganization] = true
    session[:suborganization_members_limit] = 50

    post :signup, user: {login: 'quire', password: 'quire', password_confirmation: 'quire', name: 'quire', email: 'test@example.com'}
    assert_response :redirect
    assert_redirected_to subcommunity.url

    user = Profile['quire']
    assert user
    assert_includes subcommunity.members, user
  end

  private

  def disable_signup_bot_check environment = Environment.default
    environment.min_signup_delay = 0
    environment.save!
  end

end
