require 'test_helper'

class ContainerBlockPlugin::ContainerBlockTest < ActiveSupport::TestCase

  def setup
    @block = ContainerBlockPlugin::ContainerBlock.new
    @block.stubs(:owner).returns(Environment.default)
  end

  should 'describe yourself' do
    refute ContainerBlockPlugin::ContainerBlock.description.blank?
  end

  should 'has a help' do
    refute @block.help.blank?
  end

  should 'create a box on save' do
    @block.save!
    assert @block.container_box_id
  end

  should 'created box should have nil as position' do
    @block.save!
    assert_equal nil, @block.container_box.position
  end

  should 'return created box' do
    @block.save!
    assert @block.container_box
  end

  should 'create new blocks when receive block classes' do
    @block.save!
    assert_difference 'Block.count', 1 do
      @block.block_classes = ['Block']
    end
    assert_equal Block, Block.last.class
  end

  should 'do not create blocks when nothing is passed as block classes' do
    @block.save!
    assert_no_difference 'Block.count' do
      @block.block_classes = []
    end
  end

  should 'do not create blocks when nil is passed as block classes' do
    @block.save!
    assert_no_difference 'Block.count' do
      @block.block_classes = nil
    end
  end

  should 'return a list of blocks associated with the container block' do
    @block.save!
    @block.block_classes = ['Block', 'Block']
    assert_equal [Block, Block], @block.blocks.map(&:class)
  end

  should 'return child width' do
    @block.children_settings = {1 => {:width => 10} }
    @block.save!
    assert_equal 10, @block.child_width(1)
  end

  should 'return nil in width if child do not exists' do
    @block.children_settings = {2 => {:width => 10} }
    @block.save!
    assert_equal nil, @block.child_width(1)
  end

  should 'return nil at layout_template' do
    assert_equal nil, @block.layout_template
  end

  should 'return children blocks that have container_box as box' do
    @block.save!
    child = Block.create!(:box_id => @block.container_box.id)
    assert_equal [child], @block.blocks
  end

  should 'destroy chilrend when container is removed' do
    @block.save!
    child = Block.create!(:box_id => @block.container_box.id)
    @block.destroy
    refute Block.exists?(child.id)
  end

  should 'destroy box when container is removed' do
    @block.save!
    assert_difference 'Box.count', -1 do
      @block.destroy
    end
  end

  should 'not mess up with boxes positions when destroyed' do
    env = fast_create(Environment)
    box1 = fast_create(Box, :owner_id => env.id, :owner_type => 'Environment', :position => 1)
    box2 = fast_create(Box, :owner_id => env.id, :owner_type => 'Environment', :position => 2)
    box3 = fast_create(Box, :owner_id => env.id, :owner_type => 'Environment', :position => 3)
    block = create(ContainerBlockPlugin::ContainerBlock, :box => box1)
    block.destroy
    assert_equal [1, 2, 3], [box1.reload.position, box2.reload.position, box3.reload.position]
  end

  should 'be able to change box' do
    @block.save!
    @block.box = Box.new(:owner => Environment.default)
    @block.save!
  end

  should 'not able to change box to be the same as container_box' do
    @block.save!
    @block.box = @block.container_box
    @block.save
    assert @block.errors.include?(:box_id)
  end

end
