require File.dirname(__FILE__) + '/../test_helper'

class ChangePasswordTest < ActiveSupport::TestCase

  fixtures :environments

  should 'validate' do
    data = ChangePassword.new
    assert !data.valid?
  end
  
  should 'refuse invalid username' do
    User.destroy_all

    data = ChangePassword.new
    data.login = 'unexisting'
    data.email = 'example@example.com'
    data.environment_id = Environment.default.id
    data.valid?
    assert data.errors.invalid?(:login)
  end

  should 'require a valid username' do
    User.destroy_all
    create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.valid?
    assert !data.errors.invalid?(:login)
  end

  should 'refuse incorrect e-mail address' do
    User.destroy_all
    create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.email = 'wrong@example.com'
    data.environment_id = Environment.default.id

    data.valid?
    assert !data.errors.invalid?(:login)
    assert data.errors.invalid?(:email)
  end

  should 'require the correct e-mail address' do
    User.destroy_all
    create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.email = 'test@example.com'
    data.environment_id = Environment.default.id

    data.valid?
    assert !data.errors.invalid?(:login)
    assert !data.errors.invalid?(:email)
  end

  should 'require correct passsword confirmation' do
    create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    change = ChangePassword.new
    change.login = 'testuser'
    change.email = 'test@example.com'
    change.environment_id = Environment.default.id
    change.save!

    change.status = Task::Status::FINISHED
    change.password = 'right'
    change.password_confirmation = 'wrong'
    assert !change.valid?
    assert change.errors.invalid?(:password)


    change.password_confirmation = 'right'
    assert change.valid?
  end

  should 'actually change password' do
    User.destroy_all
    person = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com').person

    change = ChangePassword.new
    change.login = 'testuser'
    change.email = 'test@example.com'
    change.environment_id = Environment.default.id
    change.save!

    change.expects(:requestor).returns(person).at_least_once

    change.password = 'newpass'
    change.password_confirmation = 'newpass'
    change.finish

    assert User.find(person.user.id).authenticated?('newpass')
  end

  should 'not require password and password confirmation when cancelling' do
    User.destroy_all
    person = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com').person

    change = ChangePassword.new
    change.login = 'testuser'
    change.email = 'test@example.com'
    change.environment_id = Environment.default.id
    change.save!

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

    c1 = ChangePassword.create!(:login => 'sample-user', :email => 'sample-user@test.com', :environment_id => e1.id)
    c2 = ChangePassword.create!(:login => 'sample-user', :email => 'sample-user@test.com', :environment_id => e2.id)

    assert_equal c1.requestor, p1
    assert_equal c2.requestor, p2
  end

  should 'have target notification description' do
    person = fast_create(Person, :identifier => 'testuser')

    change = ChangePassword.create(:login => 'testuser', :email => 'test@example.com', :environment_id => Environment.default.id)

    assert_match(/#{change.requestor.name} wants to change its password/, change.target_notification_description)
  end

  should 'deliver task created message' do
    person = fast_create(Person, :identifier => 'testuser')

    task = ChangePassword.create(:login => 'testuser', :email => 'test@example.com', :environment_id => Environment.default.id)

    email = TaskMailer.deliver_task_created(task)
    assert_match(/#{task.requestor.name} wants to change its password/, email.subject)
  end

end
