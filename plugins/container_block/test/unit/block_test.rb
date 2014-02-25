require 'test_helper'

class BlockTest < ActiveSupport::TestCase

  def setup
    @environment = fast_create(Environment)
    @box = Box.create!(:owner => @environment)
    @container = ContainerBlockPlugin::ContainerBlock.create!(:box_id => @box.id)
  end

  should 'return environment box if block owner is not a ContainerBlock' do
    block = Block.create!(:box_id => @box.id)
    assert_equal @box, block.box
  end

  should 'return container box if block owner is a ContainerBlock' do
    block = Block.create!(:box_id => @container.container_box.id)
    assert_equal @container.container_box, block.box
  end

  should 'return block owner if block onwer is not a ContainerBlock' do
    block = Block.create!(:box_id => @box.id)
    assert_equal @environment, block.owner
  end

  should 'return environment as owner if block onwer is a ContainerBlock' do
    block = Block.create!(:box_id => @container.container_box.id)
    assert_equal @environment, block.owner
  end

end
