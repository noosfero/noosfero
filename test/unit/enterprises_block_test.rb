require File.dirname(__FILE__) + '/../test_helper'

class EnterprisesBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, EnterprisesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, EnterprisesBlock.new.default_title
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

    owner.expects(:enterprises).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'link to all enterprises for profile' do
    profile = Profile.new
    profile.expects(:identifier).returns('theprofile')
    block = EnterprisesBlock.new
    block.expects(:owner).returns(profile)

    expects(:__).with('All enterprises').returns('All enterprises')
    expects(:link_to).with('All enterprises', :controller => 'profile', :profile => 'theprofile', :action => 'enterprises')

    instance_eval(&block.footer)
  end

  should 'link to all enterprises for environment' do
    env = Environment.default
    block = EnterprisesBlock.new
    block.expects(:owner).returns(env)

    expects(:__).with('All enterprises').returns('All enterprises')
    expects(:link_to).with('All enterprises', :controller => 'search', :action => 'assets', :asset => 'enterprises')
    instance_eval(&block.footer)
  end

  should 'give empty footer for unsupported owner type' do
    block = EnterprisesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

end
