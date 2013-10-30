require File.dirname(__FILE__) + '/../test_helper'

class ContainerBlockTest < ActiveSupport::TestCase
  
  def setup
    @block = ContainerBlock.new
  end

  should 'describe yourself' do
    assert !ContainerBlock.description.blank?
  end

  should 'has a help' do
    assert !@block.help.blank?
  end

  should 'create a box on save' do
    @block.save!
    assert @block.container_box_id
  end

  should 'return created box' do
    @block.save!
    assert @block.container_box
  end

  should 'create new blocks when receive block classes' do
    Block.destroy_all
    @block.save!
    @block.block_classes = ['Block']
    assert_equal 2, Block.count
    assert_equal Block, Block.last.class
  end

  should 'do not create blocks when nothing is passed as block classes' do
    Block.destroy_all
    @block.save!
    @block.block_classes = []
    assert_equal 1, Block.count
  end

  should 'do not create blocks when nil is passed as block classes' do
    Block.destroy_all
    @block.save!
    @block.block_classes = nil
    assert_equal 1, Block.count
  end

  should 'return a list of blocks associated with the container block' do
    Block.destroy_all
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

  should 'return nil at layout_templat' do
    assert_equal nil, @block.layout_template
  end

end
