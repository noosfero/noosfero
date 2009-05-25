require File.dirname(__FILE__) + '/../test_helper'

class CommunitiesBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, CommunitiesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, CommunitiesBlock.new.default_title
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
    block.expects(:owner).at_least_once.returns(owner)

    member1 = mock; member1.stubs(:id).returns(1); member1.stubs(:public_profile).returns(true)
    member2 = mock; member2.stubs(:id).returns(2); member2.stubs(:public_profile).returns(true)
    member3 = mock; member3.stubs(:id).returns(3); member3.stubs(:public_profile).returns(true)

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

    expects(:__).with('View all').returns('All communities')
    expects(:link_to).with('All communities', :controller => 'profile', :profile => 'theprofile', :action => 'communities')
    instance_eval(&block.footer)
  end

  should 'support environment as owner' do
    env = Environment.default
    block = CommunitiesBlock.new
    block.expects(:owner).returns(env)

    expects(:__).with('View all').returns('All communities')
    expects(:link_to).with('All communities', :controller => 'search', :action => 'assets', :asset => 'communities')

    instance_eval(&block.footer)
  end

  should 'give empty footer on unsupported owner type' do
    block = CommunitiesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

  should 'not list non-public communities' do
    user = create_user('testuser').person

    public_community = Community.create!(:name => 'test community 1', :identifier => 'comm1', :environment => Environment.default)
    public_community.add_member(user)

    private_community = Community.create!(:name => 'test community 2', :identifier => 'comm2', :environment => Environment.default, :public_profile => false)
    private_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal [public_community], block.profiles
  end

  should 'count number of owner communities' do
    user = create_user('testuser').person

    community1 = Community.create!(:name => 'test community 1', :identifier => 'comm1', :environment => Environment.default)
    community1.add_member(user)

    community2 = Community.create!(:name => 'test community 2', :identifier => 'comm2', :environment => Environment.default)
    community2.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

end
