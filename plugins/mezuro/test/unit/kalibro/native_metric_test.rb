require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/native_metric_fixtures"

class NativeMetricTest < ActiveSupport::TestCase

  def setup
    @hash = NativeMetricFixtures.amloc_hash
    @metric = NativeMetricFixtures.amloc
  end

  should 'create native metric from hash' do
    assert_equal @hash[:name], Kalibro::NativeMetric.new(@hash).name
  end

  should 'convert native metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end
