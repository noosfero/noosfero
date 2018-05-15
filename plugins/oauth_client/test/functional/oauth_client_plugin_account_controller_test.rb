require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  def setup
    Environment.default.enable_plugin OauthClientPlugin
  end

  should 'not render custom div if session does not contain auuth' do
    session[:oauth_data] = nil
    get :signup
    assert_no_tag :div, attributes: { id: 'oauth-signup' }
  end

  should 'render custom div if session contains auuth' do
    session[:oauth_data] = { something: 'something' }
    get :signup
    assert_tag :div, attributes: { id: 'oauth-signup' }
  end
end
