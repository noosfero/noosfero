require_relative "../test_helper"

class PluginHotSpotTest < ActiveSupport::TestCase

  class Client
    include Noosfero::Plugin::HotSpot
  end

  def setup
    @client = Client.new
    @client.stubs(:environment).returns(Environment.new)
  end

  should 'instantiate only once' do
    assert_same @client.plugins, @client.plugins
  end

end
