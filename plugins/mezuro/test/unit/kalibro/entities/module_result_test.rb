require "test_helper"

class ModuleResultTest < ActiveSupport::TestCase

  def self.fixture
    amloc_result = MetricResultTest.amloc_result
    sc_result = MetricResultTest.sc_result
    fixture = Kalibro::Entities::ModuleResult.new
    fixture.module = ModuleTest.qt_calculator
    fixture.date = DateTime.parse('Thu, 20 Oct 2011 18:26:43.151 +0000')
    fixture.grade = 10.0
    fixture.metric_results = [amloc_result, sc_result]
    fixture.compound_metrics_with_error = [CompoundMetricWithErrorTest.fixture]
    fixture
  end

  def self.fixture_hash
    amloc_result = MetricResultTest.amloc_result_hash
    sc_result = MetricResultTest.sc_result_hash
    {:module => ModuleTest.qt_calculator_hash,
      :date => DateTime.parse('Thu, 20 Oct 2011 18:26:43.151 +0000'),
      :grade => 10.0, :metric_result => [amloc_result, sc_result],
      :compound_metric_with_error => [CompoundMetricWithErrorTest.fixture_hash]}
  end

  def setup
    @hash = self.class.fixture_hash
    @result = self.class.fixture
  end

  should 'create module result from hash' do
    assert_equal @result, Kalibro::Entities::ModuleResult.from_hash(@hash)
  end

  should 'convert module result to hash' do
    assert_equal @hash, @result.to_hash
  end

end