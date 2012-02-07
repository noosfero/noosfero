require "test_helper"
class ErrorTest < ActiveSupport::TestCase

  def self.fixture
    error = Kalibro::Entities::Error.new
    error.message = 'Error message from ErrorTest'
    element1 = StackTraceElementTest.fixture
    element2 = StackTraceElementTest.fixture('errorTestMethod', 84)
    error.stack_trace = [element1, element2]
    error
  end

  def self.fixture_hash
    element1 = StackTraceElementTest.fixture_hash
    element2 = StackTraceElementTest.fixture_hash('errorTestMethod', 84)
    {:message => 'Error message from ErrorTest',
     :stack_trace_element => [element1, element2]}
  end

  def setup
    @hash = self.class.fixture_hash
    @error = self.class.fixture
  end

  should 'create error from hash' do
    assert_equal @error, Kalibro::Entities::Error.from_hash(@hash)
  end

  should 'convert error to hash' do
    assert_equal @hash, @error.to_hash
  end

end