class RangeFixtures

  Infinity = 1.0/0.0

  def self.amloc_excellent
    range = Kalibro::Entities::Range.new
    range.beginning = 0.0
    range.end = 7.0
    range.label = 'Excellent'
    range.grade = 10.0
    range.color = 'ff00ff00'
    range
  end

  def self.amloc_bad
    range = Kalibro::Entities::Range.new
    range.beginning = 19.5
    range.end = Infinity
    range.label = 'Bad'
    range.grade = 0.0
    range.color = 'ffff0000'
    range
  end

  def self.amloc_excellent_hash
    {:beginning => 0.0, :end => 7.0, :label => 'Excellent', :grade => 10.0, :color => 'ff00ff00'}
  end

  def self.amloc_bad_hash
    {:beginning => 19.5, :end => "INF", :label => 'Bad',:grade => 0.0, :color => 'ffff0000'}
  end

end
