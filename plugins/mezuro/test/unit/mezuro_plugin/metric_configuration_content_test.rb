require "test_helper"

class MetricConfigurationContentTest < ActiveSupport::TestCase
  
  def setup
    @metric_configuration = MezuroPlugin::MetricConfigurationContent.new
  end
  
  should 'be a metric configuration' do
    assert_kind_of Article, @metric_configuration
  end

  should 'have short description' do
    assert_equal 'Kalibro Configurated Metric', MezuroPlugin::MetricConfigurationContent.short_description
  end
  
  should 'have description' do
    assert_equal 'Sets of thresholds to interpret a metric', MezuroPlugin::MetricConfigurationContent.description
  end
  
  should 'have an html view' do
    assert_not_nil @metric_configuration.to_html
  end
  
  #should 'return metric configuration' do
  #  pending "Need refactoring"
  #end
  
  should 'send metric configuration to service after saving' do
    @metric_configuration.expects :send_metric_configuration_to_service
    @metric_configuration.run_callbacks :after_save
  end

  should 'send correct metric configuration to service' do
    Kalibro::Client::MetricConfigurationClient.expects(:save).with(@metric_configuration)
    @metric_configuration.send :send_metric_configuration_to_service
  end

  should 'remove metric configuration from service' do
    Kalibro::Client::MetricConfigurationClient.expects(:remove).with(@metric_configuration.name)
    @metric_configuration.send :remove_metric_configuration_from_service
  end
  
end
