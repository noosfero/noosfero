require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_snapshot_fixtures"

class RangeSnapshotTest < ActiveSupport::TestCase

  def setup
    @hash = RangeSnapshotFixtures.range_snapshot_hash
    @range_snapshot = RangeSnapshotFixtures.range_snapshot
  end

  should 'create range_snapshot from hash' do
    assert_equal @hash[:comments], Kalibro::RangeSnapshot.new(@hash).comments
  end

  should 'convert range_snapshot to hash' do
    assert_equal @hash, @range_snapshot.to_hash
  end

end
