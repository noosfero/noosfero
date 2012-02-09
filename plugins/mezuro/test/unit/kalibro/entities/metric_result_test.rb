require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_result_fixtures"

class MetricResultTest < ActiveSupport::TestCase

  def setup
    @hash = MetricResultFixtures.amloc_result_hash
    @result = MetricResultFixtures.amloc_result
  end

  should 'create metric result from hash' do
    assert_equal @result, Kalibro::Entities::MetricResult.from_hash(@hash)
  end

  should 'convert metric result to hash' do
    assert_equal @hash, @result.to_hash
  end

  should 'create appropriate metric type' do
    assert self.class.amloc_result.metric.instance_of?(Kalibro::Entities::NativeMetric)
    assert self.class.sc_result.metric.instance_of?(Kalibro::Entities::CompoundMetric)
  end

  should 'convert single descendent result to array' do
    @result.descendent_result = 1
    assert_equal [1], @result.descendent_results
  end
  
end