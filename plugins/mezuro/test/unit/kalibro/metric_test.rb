require "test_helper"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_fixtures"

class MetricTest < ActiveSupport::TestCase

  def setup
    @native_hash = MetricFixtures.amloc_hash
    @native = MetricFixtures.amloc
    @compound_hash = MetricFixtures.compound_metric_hash
    @compound = MetricFixtures.compound_metric
  end

  should 'create native metric from hash' do
    assert_equal @native_hash[:name], Kalibro::Metric.new(@native_hash).name
  end

  should 'convert native metric to hash' do
    assert_equal @native_hash, @native.to_hash
  end

  should 'create compound metric from hash' do
    assert_equal @compound_hash[:script], Kalibro::Metric.new(@compound_hash).script
  end

  should 'convert compound metric to hash' do
    assert_equal @compound_hash, @compound.to_hash
  end

end
