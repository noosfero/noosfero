require "test_helper"
class StackTraceElementTest < ActiveSupport::TestCase

  def self.fixture(method_name = 'stackTraceElementTestMethod', line_number = 42)
    stack_trace_element = Kalibro::Entities::StackTraceElement.new
    stack_trace_element.declaring_class = 'org.declaring.Class'
    stack_trace_element.method_name = method_name
    stack_trace_element.file_name = 'Class.java'
    stack_trace_element.line_number = line_number
    stack_trace_element
  end

  def self.fixture_hash(method_name = 'stackTraceElementTestMethod', line_number = 42)
    {:declaring_class => 'org.declaring.Class',
     :method_name => method_name,
     :file_name => 'Class.java',
     :line_number => line_number}
  end

  def setup
    @hash = self.class.fixture_hash
    @stack_trace_element = self.class.fixture
  end

  should 'create stack trace element from hash' do
    assert_equal @stack_trace_element, Kalibro::Entities::StackTraceElement.from_hash(@hash)
  end

  should 'convert stack trace element to hash' do
    assert_equal @hash, @stack_trace_element.to_hash
  end

end
