require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < ActiveSupport::TestCase

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
    block = MembersBlock.new
    block.limit = 2
    block.save!

    owner = mock
    block.expects(:owner).returns(owner)

    member1 = stub(:id => 1, :visible? => true)
    member2 = stub(:id => 2, :visible? => true)
    member3 = stub(:id => 3, :visible? => true)

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

    member1 = mock
    member2 = mock
    member3 = mock

    member1.stubs(:visible?).returns(true)
    member2.stubs(:visible?).returns(true)
    member3.stubs(:visible?).returns(true)

    owner.expects(:members).returns([member1, member2, member3])
    
    block = MembersBlock.new
    block.expects(:owner).returns(owner)
    assert_equal 3, block.profile_count
  end

  should 'count non-public community members' do
    community = fast_create(Community)

    private_p = fast_create(Person, :public_profile => false)
    public_p = fast_create(Person, :public_profile => true)

    community.add_member(private_p)
    community.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).at_least_once.returns(community)

    assert_equal 2, block.profile_count
  end

  should 'not count non-visible community members' do
    community = fast_create(Community)

    private_p = fast_create(Person, :visible => false)
    public_p = fast_create(Person, :visible => true)

    community.add_member(private_p)
    community.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).at_least_once.returns(community)

    assert_equal 1, block.profile_count
  end

end

