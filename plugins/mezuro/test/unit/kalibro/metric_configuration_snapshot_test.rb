require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_snapshot_fixtures"

class MetricConfigurationSnapshotTest < ActiveSupport::TestCase

  def setup
    @hash = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_hash
    @metric_configuration_snapshot = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot
  end

  should 'create metric configuration snapshot from hash' do
    assert_equal @hash[:code], Kalibro::MetricConfigurationSnapshot.new(@hash).code
  end

  should 'convert metric configuration snapshot to hash' do
    assert_equal @hash, @metric_configuration_snapshot.to_hash
  end

end
