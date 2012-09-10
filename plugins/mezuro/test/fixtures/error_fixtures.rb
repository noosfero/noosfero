require File.dirname(__FILE__) + '/stack_trace_element_fixtures'

class ErrorFixtures

  def self.error
    Kalibro::Error.new error_hash
  end

  def self.error_hash
    {
      :error_class => 'java.lang.Exception',
      :message => 'Error message from ErrorTest',
      :stack_trace_element => [
        StackTraceElementFixtures.stack_trace_element_hash('my method 1', 42),
        StackTraceElementFixtures.stack_trace_element_hash('my method 2', 84)
      ]
    }
  end
    
end
