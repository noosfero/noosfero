require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_result_fixtures"

class MetricResultTest < ActiveSupport::TestCase

  def setup
    @hash = MetricResultFixtures.native_metric_result_hash
    @result = MetricResultFixtures.native_metric_result
  end

  should 'create metric result from hash' do
    assert_equal @hash[:metric][:name], Kalibro::MetricResult.new(@hash).metric.name
  end

  should 'convert metric result to hash' do
    assert_equal @hash, @result.to_hash
  end

  should 'create appropriate metric type' do
    assert MetricResultFixtures.native_metric_result.metric.instance_of?(Kalibro::NativeMetric)
    assert MetricResultFixtures.compound_metric_result.metric.instance_of?(Kalibro::CompoundMetric)
  end

  should 'convert single descendent result to array' do
    @result.descendent_result = 1
    assert_equal [1], @result.descendent_results
  end
  
end
