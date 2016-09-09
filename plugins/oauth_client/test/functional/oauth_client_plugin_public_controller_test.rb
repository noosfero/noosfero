require 'test_helper'

class OauthClientPluginPublicControllerTest < ActionController::TestCase

  def setup
    @auth = mock
    @auth.stubs(:info).returns(mock)
    @auth.info.stubs(:email).returns("user@email.com")
    @auth.info.stubs(:name).returns("User")
    @auth.info.stubs(:nickname).returns("user")
    @auth.info.stubs(:image).returns("url.to.image.com")
    @auth.stubs(:provider).returns("testprovider")
    @auth.stubs(:uid).returns("jh12j3h12kjh312")

    request.env["omniauth.auth"] = @auth
    @environment = Environment.default
    @provider = OauthClientPlugin::Provider.create!(:name => 'provider', :strategy => 'github', :enabled => true)

    session[:provider_id] = provider.id
  end
  attr_reader :auth, :environment, :provider

  should 'redirect to signup when user is not found' do
    get :callback
    assert_match /.*\/account\/signup/, @response.redirect_url
  end

  should 'login when user already signed up' do
    create_user(@auth.info.name, email: @auth.info.email)

    get :callback
    assert session[:user].present?
  end

  should 'not login when user already signed up and the provider is disabled' do
    create_user(@auth.info.name, email: @auth.info.email)
    provider.update_attribute(:enabled, false)

    get :callback
    assert session[:user].nil?
  end

  should 'not login when user already signed up and the provider is disabled for him' do
    create_user(@auth.info.name, email: @auth.info.email)
    OauthClientPlugin::Auth.any_instance.stubs(:enabled?).returns(false)

    get :callback
    assert session[:user].nil?
  end

  should 'not duplicate oauth_auths when the same provider is used several times' do
    user = create_user(@auth.info.name, email: @auth.info.email)

    get :callback
    assert_no_difference 'user.oauth_auths.count' do
      3.times { get :callback }
    end
  end

  should 'perform external login using provider when url param is present' do
    request.env["omniauth.params"] = {"action" => "external_login"}

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert session[:external].present?
  end

  should 'not create an user when performing external login' do
    request.env["omniauth.params"] = {"action" => "external_login"}

    assert_no_difference 'User.count' do
      get :callback
    end
  end

  should 'not perform external login when the provider is disabled' do
    request.env["omniauth.params"] = {"action" => "external_login"}
    provider.update_attribute(:enabled, false)

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert session[:external].nil?
  end

  should 'not perform external login when the provider is disabled for a user' do
    request.env["omniauth.params"] = {"action" => "external_login"}
    OauthClientPlugin::GithubAuth.any_instance.stubs(:enabled?).returns(false)

    get :callback
    assert_redirected_to :controller => :account, :action => :login
    assert session[:external].nil?
  end

  should 'save provider when an external person logs in with it' do
    request.env["omniauth.params"] = {"action" => "external_login"}

    get :callback
    external_person = OauthClientPlugin::OauthExternalPerson.find_by(identifier: auth.info.nickname)
    assert_equal provider, external_person.oauth_auth.provider
  end
end
