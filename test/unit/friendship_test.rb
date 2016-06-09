require_relative "../test_helper"

class FriendshipTest < ActiveSupport::TestCase

  should 'connect a person to another' do
    p1 = create_user('person_test').person
    p2 = create_user('person_test_2').person

    f = Friendship.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      f.person = Organization.new
    end
    assert_raise ActiveRecord::AssociationTypeMismatch do
      f.friend = Organization.new
    end
    assert_nothing_raised do
      f.person = p1
      f.friend = p2
    end

    f.save!

  end

  should 'create tracked action' do
    a, b, c = create_user('a').person, create_user('b').person, create_user('c').person
    f = Friendship.new
    f.person = a
    f.friend = b
    f.save!
    ta = ActionTracker::Record.where(:target_type => "Friendship").last
    assert_equal a, ta.user
    assert_equal 'b', ta.get_friend_name[0]
    f = Friendship.new
    f.person = a
    f.friend = c
    f.save!
    ta = ActionTracker::Record.where(:target_type => "Friendship").last
    assert_equal a, ta.user
    assert_equal 'c', ta.get_friend_name[1]
  end

  should 'create tracked action for both people' do
    a, b = create_user('a').person, create_user('b').person
    f = Friendship.new
    f.person = a
    f.friend = b
    f.save!
    ta = ActionTracker::Record.where(:target_type => "Friendship").last
    assert_equal a, ta.user
    assert_equal ['b'], ta.get_friend_name
    f = Friendship.new
    f.person = b
    f.friend = a
    f.save!
    ta = ActionTracker::Record.where(:target_type => "Friendship").last
    assert_equal b, ta.user
    assert_equal ['a'], ta.get_friend_name
  end

  should 'remove friendships when a friend removal occurs' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p1.add_friend(p2, 'friends')
    p2.add_friend(p1, 'friends')

    assert_difference 'Friendship.count', -2 do
      Friendship.remove_friendship(p1, p2)
    end

    assert_not_includes p1.friends(true), p2
    assert_not_includes p2.friends(true), p1
  end

  should 'add follower when adding friend' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    assert_difference 'ProfileFollower.count', 2 do
      p1.add_friend(p2, 'friends')
      p2.add_friend(p1, 'friends')
    end

    assert_includes p1.followers(true), p2
    assert_includes p2.followers(true), p1
  end

  should 'remove follower when a friend removal occurs' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    p1.add_friend(p2, 'friends')
    p2.add_friend(p1, 'friends')

    Friendship.remove_friendship(p1, p2)

    assert_not_includes p1.followers(true), p2
    assert_not_includes p2.followers(true), p1
  end

  should 'keep friendship intact when stop following' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    p1.add_friend(p2, 'friends')
    p2.add_friend(p1, 'friends')

    p1.unfollow(p2)

    assert_includes p1.friends(true), p2
    assert_includes p2.friends(true), p1
  end

  should 'do not add friendship when start following' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    circle1 = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')
    circle2 = Circle.create!(:person=> p2, :name => "Zombies", :profile_type => 'Person')
    p1.follow(p2, circle1)
    p2.follow(p1, circle2)

    assert_not_includes p1.friends(true), p2
    assert_not_includes p2.friends(true), p1
  end
end
