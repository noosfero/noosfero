require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, MembersBlock.new
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, MembersBlock.description
  end

  should 'provide a default title' do
    assert_not_equal ProfileListBlock.new.default_title, MembersBlock.new.default_title
  end

  should 'link to "all members" page' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    expects(:_).with('View all').returns('View all')
    expects(:link_to).with('View all' , :profile => 'mytestuser', :controller => 'profile', :action => 'members').returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
  end

  should 'pick random members' do

    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.limit = 2
    block.save!

    owner = mock
    block.expects(:owner).returns(owner)

    member1 = mock; member1.stubs(:id).returns(1)
    member2 = mock; member2.stubs(:id).returns(2)
    member3 = mock; member3.stubs(:id).returns(3)

    owner.expects(:members).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'count number of owner members' do
    profile = create_user('mytestuser').person
    owner = mock

    member1 = mock; member1.stubs(:id).returns(1)
    member2 = mock; member2.stubs(:id).returns(2)
    member3 = mock; member3.stubs(:id).returns(3)

    owner.expects(:members).returns([member1, member2, member3])
    
    block = MembersBlock.new
    block.expects(:owner).returns(owner)
    assert_equal 3, block.profile_count
  end
end

