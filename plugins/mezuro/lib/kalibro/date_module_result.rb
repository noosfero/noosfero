class Kalibro::DateModuleResult < Kalibro::Model
  
  attr_accessor :date, :module_result

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def module_result=(value)
    @module_result = Kalibro::ModuleResult.to_object value
  end
  
  def result
    @module_result.grade
  end
  
end
