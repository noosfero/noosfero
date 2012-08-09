class StackTraceElementFixtures
    
  def self.stack_trace_element(method_name = 'my method name', line_number = 42)
    Kalibro::StackTraceElement.new stack_trace_element_hash(method_name, line_number)
  end

  def self.stack_trace_element_hash(method_name = 'my method name', line_number = 42)
    {
      :declaring_class => 'my.declaring.Class',
      :method_name => method_name,
      :file_name => 'MyFile.java',
      :line_number => line_number
    }
  end

end
