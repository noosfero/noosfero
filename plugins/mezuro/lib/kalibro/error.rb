class Kalibro::Error < Kalibro::Model
  
  attr_accessor :error_class, :message, :stack_trace_element, :cause

  def stack_trace_element=(value)
    @stack_trace_element = Kalibro::StackTraceElement.to_objects_array value
  end
  
  def stack_trace
    @stack_trace_element
  end

  def stack_trace=(stack_trace)
    @stack_trace_element = stack_trace
  end

  def cause=(cause_value)
    @cause = Kalibro::Error.to_object cause_value
  end

end
