require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

  should "only create a noosfero provider with a site" do
    provider = OauthClientPlugin::Provider.new(:name => 'noosfero', :strategy => 'noosfero_oauth2')
    assert_not provider.valid?

    provider.client_options = { :site => "http://noosfero.org" }
    assert provider.valid?
  end

  should "create a regular provider without a site" do
    provider = OauthClientPlugin::Provider.new(:name => 'github', :strategy => 'github')
    assert provider.valid?
  end
end
