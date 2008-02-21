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

  should 'not send e-mails' do

    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

    task = AddFriend.create!(:person => p1, :friend => p2)
    task.finish

  end

end
