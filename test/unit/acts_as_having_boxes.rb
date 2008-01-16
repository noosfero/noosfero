require File.dirname(__FILE__) + '/../test_helper'

class ActsAsHavingBoxesTest < Test::Unit::TestCase

  should 'be able to find blocks by id' do
    env = Environment.create!(:name => 'my test environment')
    env.boxes.destroy_all

    env.boxes << Box.new
    block = Block.new
    env.boxes.first.blocks << block

    assert_equal block, env.blocks.find(block.id)
  end

end
