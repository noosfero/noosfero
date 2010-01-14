require File.dirname(__FILE__) + '/../test_helper'

class FriendsBlockTest < ActiveSupport::TestCase

  include GetText

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FriendsBlock.description
  end

  should 'declare its default title' do
    FriendsBlock.any_instance.stubs(:profile_count).returns(0)
    assert_not_equal ProfileListBlock.new.default_title, FriendsBlock.new.default_title
  end

  should 'use its own finder' do
    assert_not_equal ProfileListBlock::Finder, FriendsBlock::Finder
    assert_kind_of FriendsBlock::Finder, FriendsBlock.new.profile_finder
  end

  should 'list owner friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person

    p1.add_friend(p2)
    p1.add_friend(p3)
    p1.add_friend(p4)
    p1.friends.reload

    block = FriendsBlock.new
    block.expects(:owner).returns(p1)

    assert_equivalent [p2, p3, p4], block.profiles
  end

  should 'point to list with all friends' do
    block = FriendsBlock.new
    user = mock
    user.expects(:identifier).returns('theuser')
    block.expects(:owner).returns(user)

    expects(:link_to).with('View all', :profile => 'theuser', :controller => 'profile', :action => 'friends')

    instance_eval(&block.footer)
  end

  should 'count number of owner friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person

    p1.add_friend(p2)
    p1.add_friend(p3)
    p1.add_friend(p4)

    block = FriendsBlock.new
    block.expects(:owner).returns(p1)

    assert_equal 3, block.profile_count
  end

  should 'count number of public and private people' do
    owner = create_user('testuser1').person
    private_p = fast_create(Person, {:public_profile => false})
    public_p = fast_create(Person, {:public_profile => true})

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner)

    assert_equal 2, block.profile_count
  end

  should 'not count number of invisible people' do
    owner = create_user('testuser1').person
    private_p = fast_create(Person, {:visible => false})
    public_p = fast_create(Person, {:visible => true})

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner)

    assert_equal 1, block.profile_count
  end

end
