require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase

  should 'be able to add oauth providers in a environment' do
    env = fast_create(Environment)
    env.oauth_providers << OauthClientPlugin::Provider.new(:name => 'test', :strategy => 'test')
  end

end
