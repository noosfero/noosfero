require File.dirname(__FILE__) + '/../test_helper'

class OauthClientPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = OauthClientPlugin.new(self)
    @params = {}
    @plugin.stubs(:context).returns(self)
    @environment = Environment.default
    @session = {}
    @request = mock
    @provider = OauthClientPlugin::Provider.create!(:name => 'name', :strategy => 'strategy')
  end

  attr_reader :params, :plugin, :environment, :session, :request, :provider

  should 'has extra contents for login' do
    assert plugin.login_extra_contents
  end

  should 'has no signup extra contents if no provider was enabled' do
    assert_equal '', instance_eval(&plugin.signup_extra_contents)
  end

  should 'has signup extra contents if oauth_data exists in session' do
    session[:oauth_data] = {:oauth => 'test'}
    expects(:render).with(:partial => 'account/oauth_signup').once
    instance_eval(&plugin.signup_extra_contents)
  end

  should 'define before filter for account controller' do
    assert plugin.account_controller_filters
  end

  should 'raise error if oauth email was changed' do
    request.expects(:post?).returns(true)

    oauth_data = mock
    info = mock
    oauth_data.stubs(:info).returns(info)
    oauth_data.stubs(:uid).returns('uid')
    oauth_data.stubs(:provider).returns('provider')
    info.stubs(:email).returns('test@example.com')
    session[:oauth_data] = oauth_data
    session[:provider_id] = provider.id

    params[:user] = {:email => 'test2@example.com'}
    assert_raises RuntimeError do
      instance_eval(&plugin.account_controller_filters[:block])
    end
  end

  should 'do not raise error if oauth email was not changed' do
    request.expects(:post?).returns(true)

    oauth_data = mock
    info = mock
    oauth_data.stubs(:info).returns(info)
    oauth_data.stubs(:uid).returns('uid')
    oauth_data.stubs(:provider).returns('provider')
    info.stubs(:email).returns('test@example.com')
    session[:oauth_data] = oauth_data
    session[:provider_id] = provider.id

    params[:user] = {:email => 'test@example.com'}
    instance_eval(&plugin.account_controller_filters[:block])
  end

  should 'do not raise error if oauth session is not set' do
    instance_eval(&plugin.account_controller_filters[:block])
  end

  should 'do not raise error if it is not a post' do
    request.expects(:post?).returns(false)
    params[:user] = {:email => 'test2@example.com'}

    oauth_data = mock
    oauth_data.stubs(:uid).returns('uid')
    oauth_data.stubs(:provider).returns('provider')
    session[:provider_id] = provider.id

    session[:oauth_data] = oauth_data
    instance_eval(&plugin.account_controller_filters[:block])
  end

end
