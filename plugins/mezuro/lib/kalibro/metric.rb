class Kalibro::Metric < Kalibro::Model
  
  attr_accessor :name, :compound, :scope, :description, :script, :language

  def languages
    @language
  end

  def languages=(languages)
    @language = languages
  end

  def language=(value)
    @language = Kalibro::Model.to_objects_array value
  end

end
