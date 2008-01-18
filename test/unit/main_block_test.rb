require File.dirname(__FILE__) + '/../test_helper'

class MainBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_kind_of String, MainBlock.description
    assert_not_equal Block.description, MainBlock.description
  end

end
