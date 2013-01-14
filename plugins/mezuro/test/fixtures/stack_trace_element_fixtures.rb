class StackTraceElementFixtures
    
  def self.stack_trace_element
    Kalibro::StackTraceElement.new stack_trace_element_hash
  end

  def self.stack_trace_element_hash
    {
      :declaring_class => 'my.declaring.Class',
      :method_name => 'my method name',
      :file_name => 'MyFile.java',
      :line_number => '42'
    }
  end

end
