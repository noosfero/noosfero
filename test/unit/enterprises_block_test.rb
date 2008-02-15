require File.dirname(__FILE__) + '/../test_helper'

class EnterprisesBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, EnterprisesBlock.new
  end

  should 'declare its title' do
    assert_not_equal ProfileListBlock.new.title, EnterprisesBlock.new.title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, EnterprisesBlock.description
  end

  should 'use its own finder' do
    assert_not_equal EnterprisesBlock::Finder, ProfileListBlock::Finder
    assert_kind_of EnterprisesBlock::Finder, EnterprisesBlock.new.profile_finder
  end

  should 'list owner communities' do

    block = EnterprisesBlock.new
    block.limit = 2

    owner = mock
    block.expects(:owner).returns(owner)

    member1 = mock; member1.stubs(:id).returns(1)
    member2 = mock; member2.stubs(:id).returns(2)
    member3 = mock; member3.stubs(:id).returns(3)

    owner.expects(:enterprise_memberships).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

end
