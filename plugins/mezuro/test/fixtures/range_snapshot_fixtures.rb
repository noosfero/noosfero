class RangeSnapshotFixtures

  def self.range_snapshot
    Kalibro::RangeSnapshot.new range_snapshot_hash
  end

  def self.range_snapshot_with_infinite_range
    Kalibro::RangeSnapshot.new range_snapshot_with_infinite_range_hash
  end

  def self.range_snapshot_hash
    { :beginning => "1.1", :end => "5.1", :label => "snapshot", :grade => "10.1", :color => "FF2284", :comments => "comment" }
	end

  def self.range_snapshot_with_infinite_range_hash
    { :beginning => "-INF", :end => "INF", :label => "snapshot", :grade => "10.1", :color => "FF2284", :comments => "comment" }
  end

end
