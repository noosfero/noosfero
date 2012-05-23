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
  
  should 'return metric configuration' do
    pending "Need refactoring"
  end
end
