require File.dirname(__FILE__) + '/../test_helper'

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
    f = Friendship.create! :person => a, :friend => b
    ta = ActionTracker::Record.last
    assert_equal a, ta.user
    assert_equal 'b', ta.get_friend_name[0]
    f = Friendship.create! :person => a, :friend => c
    ta = ActionTracker::Record.last
    assert_equal a, ta.user
    assert_equal 'c', ta.get_friend_name[1]
  end

  should 'create tracked action for both people' do
    a, b = create_user('a').person, create_user('b').person
    f = Friendship.create! :person => a, :friend => b
    ta = ActionTracker::Record.last
    assert_equal a, ta.user
    assert_equal ['b'], ta.get_friend_name
    f = Friendship.create! :person => b, :friend => a
    ta = ActionTracker::Record.last
    assert_equal b, ta.user
    assert_equal ['a'], ta.get_friend_name
  end

end
