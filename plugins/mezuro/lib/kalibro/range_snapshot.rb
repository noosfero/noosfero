class Kalibro::RangeSnapshot < Kalibro::Model

  attr_accessor :beginning, :end, :label, :grade, :color, :comments

  def beginning=(value)
    @beginning = ((value == "-INF") ? -1.0/0 : value.to_f)
  end

  def end=(value)
    @end = ((value == "INF") ? 1.0/0 : value.to_f)
  end

  def grade=(value)
    @grade = value.to_f
  end

end
