class Kalibro::Entities::Range < Kalibro::Entities::Entity
  
  attr_accessor :beginning, :end, :label, :grade, :color, :comments

  def beginning=(value)
    @beginning = value.to_f
    @beginning = -1.0/0.0 if value == "-INF"
  end

  def end=(value)
    @end = value.to_f
    @end = 1.0/0.0 if value == "INF"
  end

end