require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @provider = OauthClientPlugin::Provider.create!(:name => 'name', :strategy => 'strategy')
  end
  attr_reader :provider

  should 'password is not required if there is a oauth provider' do
    User.create!(:email => 'testoauth@example.com', :login => 'testoauth', :oauth_providers => [provider])
  end

  should 'associate the oauth provider with the created user' do
    user = User.create!(:email => 'testoauth@example.com', :login => 'testoauth', :oauth_providers => [provider])
    assert_equal user.oauth_providers.reload, [provider]
  end

  should 'password is required if there is a oauth provider' do
    user = User.new(:email => 'testoauth@example.com', :login => 'testoauth')
    user.save
    assert user.errors[:password].present?
  end

  should 'activate user when created with oauth' do
    user = User.create!(:email => 'testoauth@example.com', :login => 'testoauth', :oauth_providers => [provider])
    assert user.activated?
  end

  should 'not activate user when created without oauth' do
    user = fast_create(User)
    refute user.activated?
  end

  should 'not make activation code when created with oauth' do
    user = User.create!(:email => 'testoauth@example.com', :login => 'testoauth', :oauth_providers => [provider])
    refute user.activation_code
  end

  should 'make activation code when created without oauth' do
    user = User.create!(:email => 'testoauth@example.com', :login => 'testoauth', :password => 'test', :password_confirmation => 'test')
    assert user.activation_code
  end

end
