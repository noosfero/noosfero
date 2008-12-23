require File.dirname(__FILE__) + '/../test_helper'

class AddMemberTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { AddMember.new.kind_of?(Task) }
  end

  should 'actually add memberships when confirmed' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:person => p, :community => c)
    assert_difference c, :members, [p] do
      task.finish
      c.reload
    end
  end

  should 'require requestor' do
    task = AddMember.new
    task.valid?

    ok('must not validate with empty requestor') { task.errors.invalid?(:requestor_id) }

    task.requestor = Person.new
    task.valid?
    ok('must validate when requestor is given') { task.errors.invalid?(:requestor_id)}
  end

  should 'require target' do
    task = AddMember.new
    task.valid?

    ok('must not validate with empty target') { task.errors.invalid?(:target_id) }

    task.target = Person.new
    task.valid?
    ok('must validate when target is given') { task.errors.invalid?(:target_id)}
  end

  should 'send e-mails' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)

    TaskMailer.expects(:deliver_target_notification).at_least_once

    task = AddMember.create!(:person => p, :community => c)
  end

  should 'provide proper description' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)

    TaskMailer.stubs(:deliver_target_notification)

    task = AddMember.create!(:person => p, :community => c)

    assert_equal 'testuser1 wants to be a member', task.description
  end

  should 'has community alias to target' do
    t = AddMember.new
    assert_same t.target, t.community
  end

  should 'has permission to manage members' do
    t = AddMember.new
    assert_equal :manage_memberships, t.permission
  end

  should 'have roles' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'community_test')
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => [1,2,3], :person => p, :community => c)
    assert_equal [1,2,3], task.roles
  end

  should 'put member with the right roles' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'community_test')

    roles = [Profile::Roles.member, Profile::Roles.admin]
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => roles.map(&:id), :person => p, :community => c)
    task.finish

    current_roles = p.find_roles(c).map(&:role)
    assert_includes current_roles, roles[0]
    assert_includes current_roles, roles[1]
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
