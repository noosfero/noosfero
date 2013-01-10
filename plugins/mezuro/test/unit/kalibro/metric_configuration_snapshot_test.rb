require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_snapshot_fixtures"

class MetricConfigurationSnapshotTest < ActiveSupport::TestCase

  def setup
    @hash = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_hash
    @hash2 = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_hash_with_2_elements
    @metric_configuration_snapshot = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot
    @metric_configuration_snapshot2 = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_with_2_elements
  end

  should 'create and convert metric configuration snapshot from hash' do
    assert_equal @hash[:code], Kalibro::MetricConfigurationSnapshot.new(@hash).code
    assert_equal @hash[:weight].to_f, @metric_configuration_snapshot.weight
  end

  should 'create and convert metric configuration snapshot from hash with 2 elements' do
    assert_equal @hash2[:code], Kalibro::MetricConfigurationSnapshot.new(@hash2).code
    assert_equal @hash2, @metric_configuration_snapshot2.to_hash
  end

end
