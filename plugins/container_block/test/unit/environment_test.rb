require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def setup
    @environment = fast_create(Environment)

    @box = Box.create!(:owner => @environment)
    @block = Block.create!(:box => @box)

    @container = ContainerBlockPlugin::ContainerBlock.create!(:box => @box)
  end

  should 'return blocks as usual' do
    assert_equal [@block, @container], @environment.blocks
  end

  should 'return blocks with container children' do
    child = Block.create!(:box => @container.container_box)
    assert_equal [@block, @container, child], @environment.blocks
  end

  should 'return block with id at find method' do
    assert_equal @block, @environment.blocks.find(@block.id)
  end

  should 'return child block with id at find method' do
    child = Block.create!(:box => @container.container_box)
    assert_equal child, @environment.blocks.find(child.id)
  end

end
