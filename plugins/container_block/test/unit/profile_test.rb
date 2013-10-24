require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)

    @box = Box.create!(:owner => @profile)
    @block = Block.create!(:box => @box)

    @container_box = Box.create!(:owner => @profile)
    @container = ContainerBlock.create!(:box => @container_box)
  end

  should 'return blocks as usual' do
    assert_equal [@block, @container], @profile.blocks
  end

  should 'return block with id at find method' do
    assert_equal @block, @profile.blocks.find(@block.id)
  end

  should 'return child block with id at find method' do
    block = Block.create!(:box => @container_box)
    @container.save!
    assert_equal @block, @profile.blocks.find(@block.id)
  end

end
