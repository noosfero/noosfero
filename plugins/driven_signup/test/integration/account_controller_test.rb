require 'test_helper'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionDispatch::IntegrationTest

  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    e = Environment.default
    e.enable 'skip_new_user_email_confirmation', true
    disable_signup_bot_check e
  end

  should 'use the parameters' do
    token = '131324'
    Environment.default.driven_signup_auths.create! token: token
    community = create Community, name: 'base', identifier: 'base1'
    subcommunity = create Community, name: 'sub', identifier: 'base11'
    subcommunity.reload

    # simulate DrivenSignupPlugin::AccountController
    session[:driven_signup] = true
    session[:base_organization] = community.identifier
    session[:find_suborganization] = true
    session[:suborganization_members_limit] = 50

    post url_for(controller: 'driven_signup_plugin/account', action: :signup, token: token, signup: {login: 'quire', name: 'quire', email: 'test@example.com'})
    assert_response :redirect
    assert_redirected_to url_for(controller: '/account', action: :signup, user: {login: 'quire', email: 'test@example.com',},
                                 profile_data: {name: 'quire'})
  end

  private

  def disable_signup_bot_check environment = Environment.default
    environment.min_signup_delay = 0
    environment.save!
  end

end
