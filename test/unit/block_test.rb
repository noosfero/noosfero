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

end
