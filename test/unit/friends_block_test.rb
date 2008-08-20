require File.dirname(__FILE__) + '/../test_helper'

class FriendsBlockTest < ActiveSupport::TestCase

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FriendsBlock.description
  end

  should 'declare its default title' do
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

    block = FriendsBlock.new
    block.expects(:owner).returns(p1)

    assert_equivalent [p2, p3, p4], block.profiles
  end

  should 'point to list with all friends' do
    block = FriendsBlock.new
    user = mock
    user.expects(:identifier).returns('theuser')
    block.expects(:owner).returns(user)

    def self._(s); s; end
    def self.gettext(s); s; end
    expects(:link_to).with('All friends', :profile => 'theuser', :controller => 'profile', :action => 'friends')

    instance_eval(&block.footer)
  end

end
