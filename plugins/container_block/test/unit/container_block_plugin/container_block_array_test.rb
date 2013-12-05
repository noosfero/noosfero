require File.dirname(__FILE__) + '/../test_helper'

class ContainerBlockPlugin::ContainerBlockArrayTest < ActiveSupport::TestCase

  attr_reader :blocks

  include ContainerBlockPlugin::ContainerBlockArray

  def setup
    @blocks = []

    @environment = fast_create(Environment)
    @container_box = Box.new(:owner => @environment)
    @container = ContainerBlockPlugin::ContainerBlock.new(:box => @container_box)
  end

  should 'return blocks as usual' do
    @blocks << Block.new
    assert_equal @blocks, blocks_without_container_block_plugin
  end

  should 'return blocks and container block children' do
    @container.save!
    @container_box.blocks << Block.new
    @blocks.concat([Block.new, @container])
    assert_equal @blocks + @container.blocks, blocks_without_container_block_plugin
  end

end
