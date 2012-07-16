class Kalibro::StackTraceElement < Kalibro::Model
  
  attr_accessor :declaring_class, :method_name, :file_name, :line_number

  def line_number=(value)
    @line_number = value.to_i
  end

end
