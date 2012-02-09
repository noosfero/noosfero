require "test_helper"
class MetricResultTest < ActiveSupport::TestCase

  def self.amloc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = NativeMetricTest.amloc
    result.value = 0.0
    result.descendent_results = [40.0, 42.0]
    result.range = RangeTest.amloc_excellent
    result
  end

  def self.sc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = CompoundMetricTest.sc
    result.value = 1.0
    result.descendent_results = [2.0, 42.0]
    result
  end

  def self.amloc_result_hash
    {:metric => NativeMetricTest.amloc_hash,
      :value => 0.0, :descendent_result => [40.0, 42.0],
      :range => RangeTest.amloc_excellent_hash}
  end

  def self.sc_result_hash
    {:metric => CompoundMetricTest.sc_hash,
      :value => 1.0, :descendent_result => [2.0, 42.0]}
  end

  def setup
    @hash = self.class.amloc_result_hash
    @result = self.class.amloc_result
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