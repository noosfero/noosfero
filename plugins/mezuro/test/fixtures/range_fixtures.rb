class RangeFixtures

  Infinity = 1.0/0.0

  def self.range_excellent
    Kalibro::Range.new range_excellent_hash
  end

  def self.range_bad
    Kalibro::Range.new range_bad_hash
  end

  def self.range_excellent_hash
    {:beginning => 0.0, :end => 7.0, :label => 'Excellent', :grade => 10.0, :color => 'ff00ff00'}
  end

  def self.range_bad_hash
    {:beginning => 19.5, :end => "INF", :label => 'Bad',:grade => 0.0, :color => 'ffff0000'}
  end

end
