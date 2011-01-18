require File.dirname(__FILE__) + '/../test_helper'

class InviteMemberTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { InviteMember.new.kind_of?(Task) }
  end

  should 'actually add as member when confirmed' do
    person = fast_create(Person)
    friend = fast_create(Person)
    friend.stubs(:user).returns(User.new(:email => 'garotos@podres.punk.oi'))
    person.stubs(:user).returns(User.new(:email => 'suburbio-operario@podres.podres'))
    community = fast_create(Community)

    assert_equal [], community.members

    task = InviteMember.create!(:person => person, :friend => friend, :community_id => community.id)
    task.finish
    community.reload

    ok('friend is member of community') { community.members.include?(friend) }
  end

  should 'require community (person inviting other to be a member)' do
    task = InviteMember.new
    task.valid?

    ok('community is required') { task.errors.invalid?(:community_id) }
  end

  should 'require friend email if no target given (person being invited)' do
    task = InviteMember.new
    task.valid?

    ok('friend_email is required') { task.errors.invalid?(:friend_email) }
  end

  should 'dont require friend email if target given (person being invited)' do
    task = InviteMember.new(:target => create_user('testuser2').person)
    task.valid?

    ok('friend_email isnt required') { !task.errors.invalid?(:friend_email) }
  end

  should 'require target (person being invited) if no friend email given' do
    task = InviteMember.new
    task.valid?

    ok('target is required') { task.errors.invalid?(:target_id) }
  end

  should 'dont require target (person being invited) if friend email given' do
    task = InviteMember.new(:friend_email => "test@test.com")
    task.valid?

    ok('target isn required') { !task.errors.invalid?(:target_id) }
  end

  should 'not send e-mails to requestor' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

    task = InviteMember.create!(:person => p1, :friend => p2, :community_id => fast_create(Community).id)
    task.finish
  end

  should 'send e-mails to friend if friend_email given' do
    p1 = create_user('testuser1').person

    TaskMailer.expects(:deliver_invitation_notification).once

    task = InviteMember.create!(:person => p1, :friend_email => 'test@test.com', :message => '<url>', :community_id => fast_create(Community).id)
  end

  should 'not send e-mails to friend if target given (person being invited)' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    TaskMailer.expects(:deliver_invitation_notification).never

    task = InviteMember.create!(:person => p1, :friend => p2, :community_id => fast_create(Community).id)
  end

  should 'not invite yourself' do
    p = create_user('testuser1').person

    task1 = InviteMember.new(:person => p, :friend => p, :message => 'click here: <url>')
    assert !task1.save

    task2 = InviteMember.new(:person => p, :friend_name => 'Myself', :friend_email => p.user.email, :message => 'click here: <url>')
    assert !task2.save
  end

end

