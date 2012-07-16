require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/stack_trace_element_fixtures"

class StackTraceElementTest < ActiveSupport::TestCase

  def setup
    @hash = StackTraceElementFixtures.stack_trace_element_hash
    @stack_trace_element = StackTraceElementFixtures.stack_trace_element
  end

  should 'create stack trace element from hash' do
    assert_equal @hash[:method_name], Kalibro::StackTraceElement.new(@hash).method_name
  end

  should 'convert stack trace element to hash' do
    assert_equal @hash, @stack_trace_element.to_hash
  end

end
