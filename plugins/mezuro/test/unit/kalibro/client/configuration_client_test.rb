require "test_helper"
class ConfigurationClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('Configuration').returns(@port)
    @client = Kalibro::Client::ConfigurationClient.new
  end

  should 'save configuration' do
    configuration = ConfigurationTest.kalibro_configuration
    @port.expects(:request).with(:save_configuration, {:configuration => configuration.to_hash})
    @client.save(configuration)
  end

  should 'get configuration names (zero)' do
    @port.expects(:request).with(:get_configuration_names).returns({})
    assert_equal [], @client.configuration_names
  end

  should 'get configuration names (one)' do
    name = 'Kalibro for Java'
    @port.expects(:request).with(:get_configuration_names).returns({:configuration_name => name})
    assert_equal [name], @client.configuration_names
  end

  should 'get configuration names' do
    names = ['Kalibro for Java', 'ConfigurationClientTest configuration']
    @port.expects(:request).with(:get_configuration_names).returns({:configuration_name => names})
    assert_equal names, @client.configuration_names
  end

  should 'get configuration by name' do
    configuration = ConfigurationTest.kalibro_configuration
    request_body = {:configuration_name => configuration.name}
    response_hash = {:configuration => configuration.to_hash}
    @port.expects(:request).with(:get_configuration, request_body).returns(response_hash)
    assert_equal configuration, @client.configuration(configuration.name)
  end

  should 'remove configuration by name' do
    name = 'ConfigurationClientTest'
    @port.expects(:request).with(:remove_configuration, {:configuration_name => name})
    @client.remove(name)
  end

end