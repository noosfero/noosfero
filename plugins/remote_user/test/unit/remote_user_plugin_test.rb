require 'test_helper'
require_relative '../../../../test/api/test_helper'

class RemoteUserPluginTest < ActiveSupport::TestCase
  should 'call remote user hotspot to authenticate in API' do
    environment = Environment.default
    environment.enable_plugin(RemoteUserPlugin)
    RemoteUserPlugin.any_instance.expects(:api_custom_login).once
    get "/api/v1/people/me"
  end
end
