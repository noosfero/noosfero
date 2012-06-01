require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/compound_metric_fixtures"

class CompoundMetricTest < ActiveSupport::TestCase

  def setup
    @hash = CompoundMetricFixtures.sc_hash
    @metric = CompoundMetricFixtures.sc
  end

  should 'create compound metric from hash' do
    assert_equal @metric, Kalibro::Entities::CompoundMetric.from_hash(@hash)
  end

  should 'convert compound metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end