require File.dirname(__FILE__) + '/../test_helper'

class BlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_kind_of String, Block.description
  end

  should 'store settings in a hash' do
    block = Block.new

    assert_kind_of Hash, block.settings
    block.save!

    assert_kind_of Hash, Block.find(block.id).settings
  end
  
  
  should 'access owner through box' do
    user = create_user('testinguser').person

    box = Box.create!(:owner => user)

    block = Block.new
    block.box = box
    block.save!

    assert_equal user, block.owner
  end

  should 'have no owner when there is no box' do
    assert_nil Block.new.owner
  end

  should 'be able to declare settings items' do
    block_class = Class.new(Block)

    block = block_class.new
    assert !block.respond_to?(:limit)
    assert !block.respond_to?(:limit=)

    block_class.settings_item :limit

    assert_respond_to block, :limit
    assert_respond_to block, :limit=

    assert_nil block.limit
    block.limit = 10
    assert_equal 10, block.limit

    assert_equal({ :limit => 10}, block.settings)
  end

  should 'generate CSS class name' do
    block = Block.new
    block.class.expects(:name).returns('SomethingBlock')
    assert_equal 'something-block', block.css_class_name
  end

end
