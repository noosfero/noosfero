require File.dirname(__FILE__) + '/stack_trace_element_fixtures'

class ThrowableFixtures

  def self.throwable
    Kalibro::Throwable.new throwable_hash
  end

  def self.throwable_hash
    {
      :target_string => 'Target String',
      :message => 'Throwable message from ThrowableTest',
      :stack_trace_element => [
        StackTraceElementFixtures.stack_trace_element_hash, StackTraceElementFixtures.stack_trace_element_hash
      ]
    }
  end
    
end
