class Kalibro::Entities::Error < Kalibro::Entities::Entity
  
  attr_accessor :error_class, :message, :stack_trace_element, :cause

  def stack_trace_element=(value)
    @stack_trace_element = to_entity_array(value, Kalibro::Entities::StackTraceElement)
  end
  
  def stack_trace
    @stack_trace_element
  end

  def stack_trace=(stack_trace)
    @stack_trace_element = stack_trace
  end

  def cause=(cause_value)
    @cause = to_entity(cause_value, Kalibro::Entities::Error)
  end

end
