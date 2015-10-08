require_relative "../test_helper"

class AddMemberTest < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
    @community = fast_create(Community)
  end
  attr_reader :person, :community


  should 'be a task' do
    ok { AddMember.new.kind_of?(Task) }
  end

  should 'actually add memberships when confirmed' do
    community.update_attribute(:closed, true)
    TaskMailer.stubs(:deliver_target_notification)
    task = fast_create(AddMember, :requestor_id => person.id, :target_id => community.id, :target_type => 'Community')
    task.finish

    assert_equal [person], community.members
  end

  should 'make member role the default role' do
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => ["0", "0", nil], :person => person, :organization => community)
    task.finish

    assert_equal [person], community.members
  end

  should 'require requestor' do
    task = AddMember.new
    task.valid?

    ok('must not validate with empty requestor') { task.errors[:requestor_id.to_s].present? }

    task.requestor = Person.new
    task.valid?
    ok('must validate when requestor is given') { task.errors[:requestor_id.to_s].present?}
  end

  should 'require target' do
    task = AddMember.new
    task.valid?

    ok('must not validate with empty target') { task.errors[:target_id.to_s].present? }

    task.target = Person.new
    task.valid?
    ok('must validate when target is given') { task.errors[:target_id.to_s].present?}
  end

  should 'send e-mails' do
    community.update_attribute(:closed, true)
    community.stubs(:notification_emails).returns(["adm@example.com"])

    mailer = mock
    mailer.expects(:deliver).at_least_once
    TaskMailer.expects(:target_notification).returns(mailer).at_least_once

    task = AddMember.create!(:person => person, :organization => community)
  end

  should 'has permission to manage members' do
    t = AddMember.new
    assert_equal :manage_memberships, t.permission
  end

  should 'have roles' do
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => [1,2,3], :person => person, :organization => community)
    assert_equal [1,2,3], task.roles
  end

  should 'put member with the right roles' do
    roles = [Profile::Roles.member(community.environment.id), Profile::Roles.admin(community.environment.id)]
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => roles.map(&:id), :person => person, :organization => community)
    task.finish

    current_roles = person.find_roles(community).map(&:role)
    assert_includes current_roles, roles[0]
    assert_includes current_roles, roles[1]
  end

  should 'override target notification message method from Task' do
    task = AddMember.new(:person => person, :organization => community)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'ignore roles with id zero' do
    role = Profile::Roles.member(community.environment.id)
    TaskMailer.stubs(:deliver_target_notification)
    task = AddMember.create!(:roles => ["0", role.id, nil], :person => person, :organization => community)
    task.finish

    current_roles = person.find_roles(community).map(&:role)
    assert_includes current_roles, role
  end

  should 'have target notification message' do
    task = AddMember.new(:person => person, :organization => community)

    assert_match(/#{person.name} wants to be a member of '#{community.name}'.*[\n]*.*to accept or reject/, task.target_notification_message)
  end

  should 'have target notification description' do
    task = AddMember.new(:person => person, :organization => community)

    assert_match(/#{task.requestor.name} wants to be a member of '#{community.name}'/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = AddMember.new(:person => person, :organization => community)

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver
    assert_match(/#{task.requestor.name} wants to be a member of '#{community.name}'/, email.subject)
  end

  should 'notification description with requestor email if requestor email is public' do
    new_person = create_user('testuser').person
    new_person.update_attributes!({:fields_privacy => {:email => 'public'}})

    task = AddMember.new(:person => new_person, :organization => community)

    assert_match(/\(#{task.requestor.email}\)/, task.target_notification_description)
  end

  should 'notification description without requestor email if requestor email is not public' do
    new_person = create_user('testuser').person
    new_person.update_attributes!({:fields_privacy => {:email => '0'}})

    task = AddMember.new(:person => new_person, :organization => community)

    assert_not_match(/\(#{task.requestor.email}\)/, task.target_notification_description)
  end
end
