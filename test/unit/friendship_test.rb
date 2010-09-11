require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase

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
    f = Friendship.create! :person => create_user('a').person, :friend => create_user('b').person
    ta = ActionTracker::Record.last
    person = Person.first
    assert_equal person.name, ta.user.name
    assert_equal 'b', ta.get_friend_name[0]
    f = Friendship.create! :person => create_user('a').person, :friend => create_user('c').person
    ta = ActionTracker::Record.last
    assert_equal person.name, ta.user.name
    assert_equal 'c', ta.get_friend_name[1]
  end

  should 'create tracked action only if they are not friends yet' do
    a, b = create_user('a').person, create_user('b').person
    f = Friendship.create! :person => a, :friend => b
    assert_equal ['b'], ActionTracker::Record.last.get_friend_name
    f = Friendship.create! :person => b, :friend => a
    assert_equal ['b'], ActionTracker::Record.last.get_friend_name
  end

end
