require File.dirname(__FILE__) + '/stack_trace_element_fixtures'

class ErrorFixtures

  def self.create
    error = Kalibro::Entities::Error.new
    error.error_class = 'java.lang.Exception'
    error.message = 'Error message from ErrorTest'
    error.stack_trace = [
      StackTraceElementFixtures.create('my method 1', 42),
      StackTraceElementFixtures.create('my method 2', 84)]
    error
  end

  def self.create_hash
    {:error_class => 'java.lang.Exception', :message => 'Error message from ErrorTest',
      :stack_trace_element => [
        StackTraceElementFixtures.create_hash('my method 1', 42),
        StackTraceElementFixtures.create_hash('my method 2', 84)]}
  end
    
end
