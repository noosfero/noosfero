class StackTraceElementFixtures
    
  def self.create(method_name = 'my method name', line_number = 42)
    element = Kalibro::Entities::StackTraceElement.new
    element.declaring_class = 'my.declaring.Class'
    element.method_name = method_name
    element.file_name = 'MyFile.java'
    element.line_number = line_number
    element
  end

  def self.create_hash(method_name = 'my method name', line_number = 42)
    {:declaring_class => 'my.declaring.Class', :method_name => method_name, :file_name => 'MyFile.java',
     :line_number => line_number}
  end

end
