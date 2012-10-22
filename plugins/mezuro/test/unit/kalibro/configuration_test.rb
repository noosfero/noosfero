require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class ConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = ConfigurationFixtures.configuration_hash
    @configuration = ConfigurationFixtures.configuration
    @configuration_content = ConfigurationFixtures.configuration_content([])
  end

  should 'initialize configuration' do
    assert_equal @hash[:name], Kalibro::Configuration.new(@hash).name
  end

  should 'convert configuration to hash' do
    assert_equal @hash, @configuration.to_hash
  end

  should 'return true when configuration is saved successfully' do
    Kalibro::Configuration.expects(:request).with("Configuration", :save_configuration, {:configuration => @configuration.to_hash})
    assert @configuration.save
  end

  should 'return false when configuration is not saved successfully' do
    Kalibro::Configuration.expects(:request).with("Configuration", :save_configuration, {:configuration => @configuration.to_hash}).raises(Exception.new)
    assert !(@configuration.save)
  end
  
  should 'get all configuration names' do
    names = ['Kalibro for Java', 'ConfigurationClientTest configuration']
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration_names).returns({:configuration_name => names})
    assert_equal names, Kalibro::Configuration.all_names
  end

  should 'find configuration by name' do
    request_body = {:configuration_name => @configuration.name}
    response_hash = {:configuration => @configuration.to_hash}
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, request_body).returns(response_hash)
    assert_equal @configuration.name, Kalibro::Configuration.find_by_name(@configuration.name).name
  end

  should 'return nil when configuration doesnt exist' do
    request_body = {:configuration_name => @configuration.name}
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, request_body).raises(Exception.new)
    assert_raise Exception do
      Kalibro::Configuration.find_by_name(@configuration.name)
    end
  end

  should 'destroy configuration by name' do
    Kalibro::Configuration.expects(:request).with("Configuration", :remove_configuration, {:configuration_name => @configuration.name})
    @configuration.destroy
  end
end
