require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/compound_metric_fixtures"

class CompoundMetricTest < ActiveSupport::TestCase

  def setup
    @hash = CompoundMetricFixtures.compound_metric_hash
    @metric = CompoundMetricFixtures.compound_metric
  end

  should 'create compound metric from hash' do
    assert_equal @hash[:script], Kalibro::CompoundMetric.new(@hash).script
  end

  should 'convert compound metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end
