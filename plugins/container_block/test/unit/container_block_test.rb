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

end
