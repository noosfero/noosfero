class ErrorFixtures

  def self.create
    error = Kalibro::Entities::Error.new
    error.message = 'Error message from ErrorTest'
    error.stack_trace = [
      StackTraceElementFixtures.create('my method 1', 42),
      StackTraceElementFixtures.create('my method 2', 84)]
    error
  end

  def self.create_hash
    {:message => 'Error message from ErrorTest', :stack_trace_element => [
        StackTraceElementFixtures.create_hash('my method 1', 42),
        StackTraceElementFixtures.create_hash('my method 2', 84)]}
  end
    
end
