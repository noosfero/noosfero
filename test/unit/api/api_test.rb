require_relative 'test_helper'

class MyPlugin < Noosfero::Plugin;end
class MyPlugin::API;end

class APITest < ActiveSupport::TestCase

  should 'endpoint should not be available if its plugin is unavailable' do
    endpoint = mock()
    environment = Environment.default
    environment.stubs(:plugin_enabled?).returns(false)
    endpoint.stubs(:options).returns({:for => MyPlugin::API})

    assert Noosfero::API::API.endpoint_unavailable?(endpoint, environment)
  end

  should 'endpoint should be available if its plugin is available' do
    class MyPlugin < Noosfero::Plugin;end
    class MyPlugin::API;end

    endpoint = mock()
    environment = Environment.default
    environment.stubs(:plugin_enabled?).returns(true)
    endpoint.stubs(:options).returns({:for => MyPlugin::API})

    assert !Noosfero::API::API.endpoint_unavailable?(endpoint, environment)
  end

end
