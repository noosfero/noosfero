require File.dirname(__FILE__) + '/../test_helper'

class InviteFriendTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { InviteFriend.new.kind_of?(Task) }
  end

  should 'actually create friendships (two way) when confirmed' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    task = InviteFriend.create!(:person => p1, :friend => p2)

    assert_difference Friendship, :count, 2 do
      task.finish
    end

    p1.friends.reload
    p2.friends.reload

    ok('p1 should have p2 as friend') { p1.friends.include?(p2) }
    ok('p2 should have p1 as friend') { p2.friends.include?(p1) }
  end

  should 'require requestor (person inviting other as friend)' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with empty requestor') { task.errors.invalid?(:requestor_id) }

    task.requestor = create_user('testuser2').person
    task.valid?
    ok('must validate when requestor is given') { !task.errors.invalid?(:requestor_id)}
  end

  should 'require friend email if no target given (person being invited)' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with empty target email') { task.errors.invalid?(:friend_email) }

    task.friend_email = 'test@test.com'
    task.valid?
    ok('must validate when target email is given') { !task.errors.invalid?(:friend_email)}
  end

  should 'dont require friend email if target given (person being invited)' do
    task = InviteFriend.new(:target => create_user('testuser2').person)
    task.valid?

    ok('must validate with empty target email') { !task.errors.invalid?(:friend_email) }
  end

  should 'require target (person being invited) if no friend email given' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with no target') { task.errors.invalid?(:target_id) }

    task.target =  create_user('testuser2').person
    task.valid?
    ok('must validate when target is given') { !task.errors.invalid?(:target_id)}
  end

  should 'dont require target (person being invited) if friend email given' do
    task = InviteFriend.new(:friend_email => "test@test.com")
    task.valid?

    ok('must validate with no target') { !task.errors.invalid?(:target_id) }
  end

  should 'require message with <url> tag if no target given' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with no message') { task.errors.invalid?(:message) }

    task.message = 'a simple message'
    task.valid?
    ok('must not validate with no <url> tag in message') { task.errors.invalid?(:message) }

    task.message = 'a simple message with <url>'
    task.valid?
    ok('must validate when message is given with <url> tag') { !task.errors.invalid?(:message)}
  end

  should 'dont require message if target given (person being invited)' do
    task = InviteFriend.new(:target => create_user('testuser2').person)
    task.valid?

    ok('must validate with no target') { !task.errors.invalid?(:message) }
  end

  should 'not send e-mails to requestor' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

    task = InviteFriend.create!(:person => p1, :friend => p2)
    task.finish
  end

  should 'send e-mails to friend if friend_email given' do
    p1 = create_user('testuser1').person

    TaskMailer.expects(:deliver_invitation_notification).once

    task = InviteFriend.create!(:person => p1, :friend_email => 'test@test.com', :message => '<url>')
  end

  should 'not send e-mails to friend if target given (person being invited)' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_invitation_notification).never

    task = InviteFriend.create!(:person => p1, :friend => p2)
  end

  should 'provide proper description' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

    task = InviteFriend.create!(:person => p1, :friend => p2)

    assert_equal 'testuser1 wants to be your friend.', task.description
  end

  should 'has permission to manage friends' do
    t = InviteFriend.new
    assert_equal :manage_friends, t.permission
  end

end
