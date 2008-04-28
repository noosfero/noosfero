require File.dirname(__FILE__) + '/../test_helper'

class CommunitiesBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, CommunitiesBlock.new
  end

  should 'declare its title' do
    assert_not_equal ProfileListBlock.new.title, CommunitiesBlock.new.title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, CommunitiesBlock.description
  end

  should 'use its own finder' do
    assert_not_equal CommunitiesBlock::Finder, ProfileListBlock::Finder
    assert_kind_of CommunitiesBlock::Finder, CommunitiesBlock.new.profile_finder
  end

  should 'list owner communities' do

    block = CommunitiesBlock.new
    block.limit = 2

    owner = mock
    block.expects(:owner).returns(owner)

    member1 = mock; member1.stubs(:id).returns(1)
    member2 = mock; member2.stubs(:id).returns(2)
    member3 = mock; member3.stubs(:id).returns(3)

    owner.expects(:communities).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'link to all communities of profile' do
    profile = Profile.new
    profile.expects(:identifier).returns("theprofile")

    block = CommunitiesBlock.new
    block.expects(:owner).returns(profile)

    expects(:_).with('All communities').returns('All communities')
    expects(:link_to).with('All communities', :controller => 'profile', :profile => 'theprofile', :action => 'communities')
    instance_eval(&block.footer)
  end

  should 'support environment as owner' do
    env = Environment.default
    block = CommunitiesBlock.new
    block.expects(:owner).returns(env)

    expects(:_).with('All communities').returns('All communities')
    expects(:link_to).with('All communities', :controller => 'search', :action => 'assets', :asset => 'communities')

    instance_eval(&block.footer)
  end

  should 'give empty footer on unsupported owner type' do
    block = CommunitiesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

end
