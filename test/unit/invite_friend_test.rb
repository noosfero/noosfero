require_relative "../test_helper"

class InviteFriendTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { InviteFriend.new.kind_of?(Task) }
  end

  should 'actually create friendships (two way) when confirmed' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    task = InviteFriend.create!(:person => p1, :friend => p2)

    assert_difference 'Friendship.count', 2 do
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

    ok('must not validate with empty requestor') { task.errors[:requestor_id.to_s].present? }

    task.requestor = create_user('testuser2').person
    task.valid?
    ok('must validate when requestor is given') { !task.errors[:requestor_id.to_s].present?}
  end

  should 'require friend email if no target given (person being invited)' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with empty target email') { task.errors[:friend_email.to_s].present? }

    task.friend_email = 'test@test.com'
    task.valid?
    ok('must validate when target email is given') { !task.errors[:friend_email.to_s].present?}
  end

  should 'dont require friend email if target given (person being invited)' do
    task = InviteFriend.new(:target => create_user('testuser2').person)
    task.valid?

    ok('must validate with empty target email') { !task.errors[:friend_email.to_s].present? }
  end

  should 'require target (person being invited) if no friend email given' do
    task = InviteFriend.new
    task.valid?

    ok('must not validate with no target') { task.errors[:target_id.to_s].present? }

    task.target =  create_user('testuser2').person
    task.valid?
    ok('must validate when target is given') { !task.errors[:target_id.to_s].present?}
  end

  should 'dont require target (person being invited) if friend email given' do
    task = InviteFriend.new(:friend_email => "test@test.com")
    task.valid?

    ok('must validate with no target') { !task.errors[:target_id.to_s].present? }
  end

  should 'dont require message if target given (person being invited)' do
    task = InviteFriend.new(:target => create_user('testuser2').person)
    task.valid?

    ok('must validate with no target') { !task.errors[:message.to_s].present? }
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

    mailer = mock
    mailer.expects(:deliver).at_least_once
    TaskMailer.expects(:invitation_notification).returns(mailer).once

    task = InviteFriend.create!(:person => p1, :friend_email => 'test@test.com', :message => '<url>')
  end

  should 'not send e-mails to friend if target given (person being invited)' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_invitation_notification).never

    task = InviteFriend.create!(:person => p1, :friend => p2)
  end

  should 'has permission to manage friends' do
    t = InviteFriend.new
    assert_equal :manage_friends, t.permission
  end

  should 'not invite yourself' do
    p = create_user('testuser1').person

    task1 = InviteFriend.new(:person => p, :friend => p, :message => 'click here: <url>')
    refute task1.save

    task2 = InviteFriend.new(:person => p, :friend_name => 'Myself', :friend_email => p.user.email, :message => 'click here: <url>')
    refute task2.save
  end

  should 'have target notification description' do
    person = create_user('testuser1').person

    task = InviteFriend.create!(:person => person, :friend_email => 'test@test.com', :message => '<url>')

    assert_match(/#{task.requestor.name} wants to be your friend./, task.target_notification_description)
  end

  should 'deliver invitation notification' do
    person = create_user('testuser1').person

    task = InviteFriend.create!(:person => person, :friend_email => 'test@test.com', :message => '<url>')

    email = TaskMailer.invitation_notification(task).deliver

    assert_match(/#{task.requestor.name} wants to be your friend./, email.subject)
  end

  should 'not invite friends if there is a pending invitation' do
    person = create_user('testuser1').person
    friend = create_user('testuser2').person

    assert_difference 'InviteFriend.count' do
      InviteFriend.create({:person => person, :target => friend})
    end

    assert_no_difference 'InviteFriend.count' do
      InviteFriend.create({:person => person, :target => friend})
    end
  end
end
