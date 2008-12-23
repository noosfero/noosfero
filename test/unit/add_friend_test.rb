require File.dirname(__FILE__) + '/../test_helper'

class AddFriendTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { AddFriend.new.kind_of?(Task) }
  end

  should 'actually create friendships (two way) when confirmed' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    task = AddFriend.create!(:person => p1, :friend => p2)

    assert_difference Friendship, :count, 2 do
      task.finish
    end

    ok('p1 should have p2 as friend') { p1.friends.include?(p2) }
    ok('p2 should have p1 as friend') { p2.friends.include?(p1) }
  end

  should 'put friendships in the right groups' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    task = AddFriend.create!(:person => p1, :group_for_person => 'friend1', :friend => p2, :group_for_friend => 'friend2')

    assert_difference Friendship, :count, 2 do
      task.finish
    end

    ok('p1 should list p2 as friend1') { p1.friendships.first.group == 'friend1' }
    ok('p2 should have p1 as friend2') { p2.friendships.first.group == 'friend2' }
  end

  should 'require requestor (person adding other as friend)' do
    task = AddFriend.new
    task.valid?

    ok('must not validate with empty requestor') { task.errors.invalid?(:requestor_id) }

    task.requestor = Person.new
    task.valid?
    ok('must validate when requestor is given') { task.errors.invalid?(:requestor_id)}

  end

  should 'require target (person being added)' do
    task = AddFriend.new
    task.valid?

    ok('must not validate with empty target') { task.errors.invalid?(:target_id) }

    task.target = Person.new
    task.valid?
    ok('must validate when target is given') { task.errors.invalid?(:target_id)}
  end

  should 'send e-mails' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_target_notification).at_least_once

    task = AddFriend.create!(:person => p1, :friend => p2)
  end

  should 'provide proper description' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    task = AddFriend.create!(:person => p1, :friend => p2)

    assert_equal 'testuser1 wants to be your friend', task.description
  end

  should 'has permission to manage friends' do
    t = AddFriend.new
    assert_equal :manage_friends, t.permission
  end

  should 'not add friend twice' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    AddFriend.create!(:person => p1, :friend => p2)
    assert_raise ActiveRecord::RecordInvalid do
      AddFriend.create!(:person => p1, :friend => p2)
    end
  end

  should 'override target notification message method from Task' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    task = AddFriend.new(:person => p1, :friend => p2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

end
