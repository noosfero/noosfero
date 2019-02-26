require_relative "../test_helper"

class ActsAsHavingBoxesTest < ActiveSupport::TestCase

  should 'be able to find blocks by id' do
    env = fast_create(Environment, :name => 'An environment without blocks')

    env.boxes << Box.new
    block = Block.new
    env.boxes.first.blocks << block

    assert_equal block, env.blocks.find(block.id)
  end

end
