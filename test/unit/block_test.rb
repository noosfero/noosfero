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

end
