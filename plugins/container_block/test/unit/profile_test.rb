require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)

    @box = Box.create!(:owner => @profile)
    @block = Block.create!(:box => @box)

    @container = ContainerBlockPlugin::ContainerBlock.create!(:box => @box)
  end

  should 'return blocks as usual' do
    assert_equal [@block, @container], @profile.blocks
  end

  should 'return blocks with container children' do
    child = Block.create!(:box => @container.container_box)
    assert_equal [@block, @container, child], @profile.blocks
  end

  should 'return block with id at find method' do
    assert_equal @block, @profile.blocks.find(@block.id)
  end

  should 'return child block with id at find method' do
    child = Block.create!(:box => @container.container_box)
    assert_equal child, @profile.blocks.find(child.id)
  end

end
