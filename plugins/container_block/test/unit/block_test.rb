require File.dirname(__FILE__) + '/../test_helper'

class BlockTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.new

    @box = Box.new(:owner => @environment)
    @block = Block.new(:box => @box)

    @container_box = Box.new(:owner => @environment)
    @container = ContainerBlock.new(:box => @container_box)
  end

  should 'return block box if block owner is not a ContainerBlock' do
    assert_equal @box, @block.box
  end

  should 'return container box if block onwer is a ContainerBlock' do
    @box.owner = @container
    assert_equal @container_box, @block.box
  end

end
