require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def setup
    @environment = fast_create(Environment)

    @box = Box.create!(:owner => @environment)
    @block = Block.create!(:box => @box)

    @container_box = Box.create!(:owner => @environment)
    @container = ContainerBlock.create!(:box => @container_box)
  end

  should 'return blocks as usual' do
    assert_equal [@block, @container], @environment.blocks
  end

  should 'return block with id at find method' do
    assert_equal @block, @environment.blocks.find(@block.id)
  end

  should 'return child block with id at find method' do
    block = Block.create!(:box => @container_box)
    @container.save!
    assert_equal @block, @environment.blocks.find(@block.id)
  end

end
