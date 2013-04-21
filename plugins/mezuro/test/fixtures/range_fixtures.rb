class RangeFixtures

  def self.range
    Kalibro::Range.new range_hash
  end

  def self.created_range
    Kalibro::Range.new created_range_hash
  end
  
  def self.created_range_hash
    {:beginning => "19.5", :end => "INF", :reading_id => "1", :comments => "Test range 1"}
  end

  def self.range_hash
    {:id => "1", :beginning => "19.5", :end => "INF", :reading_id => "1", :comments => "Test range 1"}
  end

end
