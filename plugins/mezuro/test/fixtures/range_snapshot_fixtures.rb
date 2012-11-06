class RangeSnapshotFixtures

  def self.range_snapshot
    Kalibro::RangeSnapshot.new range_snapshot_hash
  end

  def self.range_snapshot_hash
    { :end => 5, :label => "snapshot", :grade => 10, :color => "FF2284", :comments => "comment" }
	end

end
