require_relative "../test_helper"

class FavoriteEnterprisesBlockTest < ActiveSupport::TestCase
  
  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, FavoriteEnterprisesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, FavoriteEnterprisesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FavoriteEnterprisesBlock.description
  end

  should 'list owner favorite enterprises' do

    block = FavoriteEnterprisesBlock.new

    owner = mock
    block.expects(:owner).returns(owner)

    list = []
    owner.expects(:favorite_enterprises).returns(list)
    
    assert_same list, block.profiles
  end

end
