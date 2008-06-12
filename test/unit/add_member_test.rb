require File.dirname(__FILE__) + '/../test_helper'

class AddMemberTest < ActiveSupport::TestCase

  should 'be a task' do
    ok { AddMember.new.kind_of?(Task) }
  end

  should 'actually add memberships when confirmed' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)
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

  should 'not send e-mails' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

    task = AddMember.create!(:person => p, :community => c)
    task.finish
  end

  should 'provide proper description' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'closed community', :closed => true)

    TaskMailer.expects(:deliver_task_finished).never
    TaskMailer.expects(:deliver_task_created).never

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
    task = AddMember.create!(:roles => [1,2,3], :person => p, :community => c)
    assert_equal [1,2,3], task.roles
  end

  should 'put member with the right roles' do
    p = create_user('testuser1').person
    c = Community.create!(:name => 'community_test')

    roles = [Profile::Roles.member, Profile::Roles.admin]
    task = AddMember.create!(:roles => roles.map(&:id), :person => p, :community => c)
    task.finish

    current_roles = p.find_roles(c).map(&:role)
    assert_includes current_roles, roles[0]
    assert_includes current_roles, roles[1]
  end

end
