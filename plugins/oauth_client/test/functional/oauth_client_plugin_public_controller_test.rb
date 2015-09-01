require 'test_helper'

class OauthClientPluginPublicControllerTest < ActionController::TestCase

  def setup
    @auth = mock
    @auth.stubs(:info).returns(mock)
    request.env["omniauth.auth"] = @auth
    @environment = Environment.default
    @provider = OauthClientPlugin::Provider.create!(:name => 'provider', :strategy => 'provider', :enabled => true)
  end
  attr_reader :auth, :environment, :provider

  should 'redirect to signup when user is not found' do
    auth.info.stubs(:email).returns("xyz123@noosfero.org")
    auth.info.stubs(:name).returns('xyz123')
    session[:provider_id] = provider.id

    get :callback
    assert_match /.*\/account\/signup/, @response.redirect_url
  end

  should 'redirect to login when user is found' do
    user = create_user
    auth.info.stubs(:email).returns(user.email)
    auth.info.stubs(:name).returns(user.name)
    session[:provider_id] = provider.id

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert_equal user.id, session[:user]
  end

  should 'do not login when the provider is disabled' do
    user = create_user
    auth.info.stubs(:email).returns(user.email)
    auth.info.stubs(:name).returns(user.name)
    session[:provider_id] = provider.id
    provider.update_attribute(:enabled, false)

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert_equal nil, session[:user]
  end

  should 'do not login when the provider is disabled for a user' do
    user = create_user
    auth.info.stubs(:email).returns(user.email)
    auth.info.stubs(:name).returns(user.name)
    session[:provider_id] = provider.id
    user.person.oauth_auths.create!(profile: user.person, provider: provider, enabled: false)

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert_equal nil, session[:user]
  end

  should 'save provider when an user login with it' do
    user = create_user
    auth.info.stubs(:email).returns(user.email)
    auth.info.stubs(:name).returns(user.name)
    session[:provider_id] = provider.id

    get :callback
    assert_equal [provider], user.oauth_providers
  end

  should 'do not duplicate relations between an user and a provider when the same provider was used again in a login' do
    user = create_user
    auth.info.stubs(:email).returns(user.email)
    auth.info.stubs(:name).returns(user.name)
    session[:provider_id] = provider.id

    get :callback
    assert_no_difference 'user.oauth_auths.count' do
      3.times { get :callback }
    end
  end

end
