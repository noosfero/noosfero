require_relative 'test_helper'

class MyPlugin < Noosfero::Plugin; end
class MyPlugin::Api; end

class ApiTest < ActiveSupport::TestCase

  should 'endpoint should not be available if its plugin is unavailable' do
    endpoint = mock()
    environment = Environment.default
    environment.stubs(:plugin_enabled?).returns(false)
    endpoint.stubs(:options).returns({:for => MyPlugin::Api})

    assert Api::App.endpoint_unavailable?(endpoint, environment)
  end

  should 'endpoint should be available if its plugin is available' do
    endpoint = mock()
    environment = Environment.default
    environment.stubs(:plugin_enabled?).returns(true)
    endpoint.stubs(:options).returns({:for => MyPlugin::Api})

    assert !Api::App.endpoint_unavailable?(endpoint, environment)
  end

end
