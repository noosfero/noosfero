require File.dirname(__FILE__) + '/test_helper'

class MainBlockTest < Test::Unit::TestCase

  include Design

  def test_main_should_always_return_true
    assert_equal true, MainBlock.new.main?
  end

end
