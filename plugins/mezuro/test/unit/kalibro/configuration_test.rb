require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class ConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = ConfigurationFixtures.configuration_hash
    @configuration = ConfigurationFixtures.configuration
    @created_configuration = ConfigurationFixtures.created_configuration
  end

  should 'initialize configuration' do
    assert_equal @hash[:name], Kalibro::Configuration.new(@hash).name
  end

  should 'convert configuration to hash' do
    assert_equal @hash, @configuration.to_hash
  end

  should 'answer if configuration exists in kalibro' do
    Kalibro::Configuration.expects(:request).with(:configuration_exists, {:configuration_id => @configuration.id}).returns({:exists => true})
    assert Kalibro::Configuration.exists?(@configuration.id)
  end

  should 'find a configuration' do
    Kalibro::Configuration.expects(:request).with(:configuration_exists, {:configuration_id => @configuration.id}).returns({:exists => true})
    Kalibro::Configuration.expects(:request).with(:get_configuration, {:configuration_id => @configuration.id}).returns(:configuration => @hash)
    assert_equal @hash[:name], Kalibro::Configuration.find(@configuration.id).name
  end

  should 'return exception when configuration doesnt exist' do
    Kalibro::Configuration.expects(:request).with(:configuration_exists, {:configuration_id => @configuration.id}).returns({:exists => false})
    assert_raise(Kalibro::Errors::RecordNotFound){Kalibro::Configuration.find(@configuration.id)}
  end

  should 'get all configurations' do
    Kalibro::Configuration.expects(:request).with(:all_configurations).returns({:configuration => [@hash]})
    assert_equal @hash[:name], Kalibro::Configuration.all.first.name
  end

  should 'return true when configuration is saved successfully' do
    id_from_kalibro = 1
    Kalibro::Configuration.expects(:request).with(:save_configuration, {:configuration => @created_configuration.to_hash}).returns(:configuration_id => id_from_kalibro)
    assert @created_configuration.save
    assert_equal id_from_kalibro, @created_configuration.id
  end

  should 'return false when configuration is not saved successfully' do
    Kalibro::Configuration.expects(:request).with(:save_configuration, {:configuration => @created_configuration.to_hash}).raises(Exception.new)
    assert !(@created_configuration.save)
    assert_nil @created_configuration.id
  end

  should 'remove existent configuration from service' do
    Kalibro::Configuration.expects(:request).with(:delete_configuration, {:configuration_id => @configuration.id})
    @configuration.destroy
  end

end
