require_relative "../test_helper"

class ChangePasswordTest < ActiveSupport::TestCase

  fixtures :environments

  def setup
    @user = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')
    @person = @user.person
  end

  attr_accessor :user, :person

  should 'require correct passsword confirmation' do
    change = ChangePassword.create!(:requestor => person)
    change.status = Task::Status::FINISHED
    change.password = 'right'
    change.password_confirmation = 'wrong'
    refute change.valid?
    assert change.errors[:password_confirmation].present?

    change.password_confirmation = 'right'
    assert change.valid?
  end

  should 'actually change password' do
    change = ChangePassword.create!(:requestor => person)
    change.password = 'newpass'
    change.password_confirmation = 'newpass'
    change.finish

    person.user.activate
    assert person.user.authenticated?('newpass')
  end

  should 'not require password and password confirmation when cancelling' do
    change = ChangePassword.create!(:requestor => person)
    assert_nothing_raised do
      change.cancel
    end
  end

  should 'has default permission' do
    t1 = Task.new
    t2 = ChangePassword.new
    assert_equal t1.permission, t2.permission
  end

  should 'search for user in the correct environment' do
    e1 = Environment.default
    e2 = fast_create(Environment)

    p1 = create_user('sample-user', :password => 'test', :password_confirmation => 'test', :email => 'sample-user@test.com', :environment => e1).person
    p2 = create_user('sample-user', :password => 'test', :password_confirmation => 'test', :email => 'sample-user@test.com', :environment => e2).person

    c1 = ChangePassword.create!(:requestor => p1)
    c2 = ChangePassword.create!(:requestor => p2)

    assert_equal c1.requestor, p1
    assert_equal c2.requestor, p2
  end

  should 'have target notification description' do
    change = ChangePassword.create!(:requestor => person)
    assert_match(/#{change.requestor.name} wants to change its password/, change.target_notification_description)
  end

  should 'deliver task created message' do
    task = ChangePassword.create!(:requestor => person)
    email = TaskMailer.generic_message('task_created', task)
    assert_match(/#{task.requestor.name} wants to change its password/, email.subject)
  end

  should 'set email template when it exists' do
    template = EmailTemplate.create!(:template_type => :user_change_password, :name => 'template1', :owner => Environment.default)
    task = ChangePassword.create!(:requestor => person)
    assert_equal template.id, task.email_template_id
  end

end
