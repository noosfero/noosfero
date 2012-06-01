require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/stack_trace_element_fixtures"

class StackTraceElementTest < ActiveSupport::TestCase

  def setup
    @hash = StackTraceElementFixtures.create_hash
    @stack_trace_element = StackTraceElementFixtures.create
  end

  should 'create stack trace element from hash' do
    assert_equal @stack_trace_element, Kalibro::Entities::StackTraceElement.from_hash(@hash)
  end

  should 'convert stack trace element to hash' do
    assert_equal @hash, @stack_trace_element.to_hash
  end

end
