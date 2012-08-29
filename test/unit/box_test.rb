require File.dirname(__FILE__) + '/../test_helper'

class BoxTest < ActiveSupport::TestCase

  should 'list allowed blocks for center box' do
    b = Box.new(:position => 1)
    assert b.acceptable_blocks.include?('main-block')
  end

  should 'list allowed blocks for box at position 2' do
    b = Box.new(:position => 2)
    assert !b.acceptable_blocks.include?('main-block')
  end

end
