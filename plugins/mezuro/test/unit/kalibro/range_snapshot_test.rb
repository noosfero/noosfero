require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_snapshot_fixtures"

class RangeSnapshotTest < ActiveSupport::TestCase

  def setup
    @hash = RangeSnapshotFixtures.range_snapshot_hash
    @range_snapshot_with_infinite_range_hash = RangeSnapshotFixtures.range_snapshot_with_infinite_range_hash
    @range_snapshot = RangeSnapshotFixtures.range_snapshot
    @range_snapshot_with_infinite_range = RangeSnapshotFixtures.range_snapshot_with_infinite_range
  end

  should 'create range_snapshot from hash' do
    range_snapshot = Kalibro::RangeSnapshot.new(@hash)
    assert_equal @hash[:comments], range_snapshot.comments
    assert_equal @hash[:beginning].to_f, range_snapshot.beginning
    assert_equal @hash[:end].to_f, range_snapshot.end
    assert_equal @hash[:grade].to_f, range_snapshot.grade
  end

  should 'create range_snapshot from hash with infinity values' do
    range_snapshot = Kalibro::RangeSnapshot.new(@range_snapshot_with_infinite_range_hash)
    assert_equal -1.0/0, range_snapshot.beginning
    assert_equal 1.0/0, range_snapshot.end
  end

  should 'convert range_snapshot to hash' do
    assert_equal @hash, @range_snapshot.to_hash
  end

end
