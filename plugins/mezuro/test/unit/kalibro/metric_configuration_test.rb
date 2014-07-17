require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MetricConfigurationTest < ActiveSupport::TestCase

  def setup
    @native_metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @native_metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @created_metric_configuration = MetricConfigurationFixtures.created_metric_configuration
  end

  should 'create metric configuration from hash' do
    metric_configuration = Kalibro::MetricConfiguration.new(@native_metric_configuration_hash)
    assert_equal @native_metric_configuration_hash[:code], metric_configuration.code
    assert_equal @native_metric_configuration_hash[:id].to_i, metric_configuration.id
    assert_equal @native_metric_configuration_hash[:reading_group_id].to_i, metric_configuration.reading_group_id
  end

  should 'convert metric configuration to hash' do
    assert_equal @native_metric_configuration_hash, @native_metric_configuration.to_hash
  end

  should 'get all metric configurations of a configuration' do
    configuration_id = 13
    request_body = { :configuration_id => configuration_id }
    response_hash = {:metric_configuration => [@native_metric_configuration_hash]}
    Kalibro::MetricConfiguration.expects(:request).with(:metric_configurations_of, request_body).returns(response_hash)    
    assert_equal @native_metric_configuration.code, Kalibro::MetricConfiguration.metric_configurations_of(configuration_id).first.code
  end

  should 'return true when metric configuration is saved successfully' do
    id_from_kalibro = 1
    configuration_id = @created_metric_configuration.configuration_id
    Kalibro::MetricConfiguration.expects(:request).with(:save_metric_configuration, {:metric_configuration => @created_metric_configuration.to_hash, :configuration_id => configuration_id}).returns(:metric_configuration_id => id_from_kalibro)
    assert @created_metric_configuration.save
    assert_equal id_from_kalibro, @created_metric_configuration.id
  end

  should 'return false when metric configuration is not saved successfully' do
    configuration_id = @created_metric_configuration.configuration_id
    Kalibro::MetricConfiguration.expects(:request).with(:save_metric_configuration, {:metric_configuration => @created_metric_configuration.to_hash, :configuration_id => configuration_id}).raises(Exception.new)
    assert !(@created_metric_configuration.save)
    assert_nil @created_metric_configuration.id
  end

  should 'destroy metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with(:delete_metric_configuration, :metric_configuration_id => @native_metric_configuration.id)
    @native_metric_configuration.destroy
  end

end
