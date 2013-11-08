require File.dirname(__FILE__) + '/../test_helper'

class ChangePasswordTest < ActiveSupport::TestCase

  fixtures :environments

  should 'validate' do
    data = ChangePassword.new(:environment_id => Environment.default)
    assert !data.valid?
  end

  should 'require only a valid value' do
    User.destroy_all
    create_user('testuser', :email => 'test@example.com')

    data = ChangePassword.new
    data.environment_id = Environment.default.id
    assert !data.valid?
    assert data.errors.invalid?(:value)

    data.value = 'testuser'
    data.valid?
    assert data.valid?

    data.value = 'test@example.com'
    assert data.valid?
  end

  should 'require correct passsword confirmation' do
    create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    change = ChangePassword.new
    change.environment_id = Environment.default.id
    change.value = 'testuser'
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
    change.environment_id = Environment.default.id
    change.value = 'testuser'
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
    change.environment_id = Environment.default.id
    change.value = 'testuser'
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

    c1 = ChangePassword.create!(:value => 'sample-user', :environment_id => e1.id)
    c2 = ChangePassword.create!(:value => 'sample-user', :environment_id => e2.id)

    assert_equal c1.requestor, p1
    assert_equal c2.requestor, p2
  end

  should 'have target notification description' do
    person = create_user('testuser').person

    change = ChangePassword.create(:value => 'testuser', :environment_id => Environment.default.id)

    assert_match(/#{change.requestor.name} wants to change its password/, change.target_notification_description)
  end

  should 'deliver task created message' do
    person = create_user('testuser').person

    task = ChangePassword.create(:value => 'testuser', :environment_id => Environment.default.id)

    email = TaskMailer.deliver_task_created(task)
    assert_match(/#{task.requestor.name} wants to change its password/, email.subject)
  end

  should 'allow extra fields provided by plugins' do
    class Plugin1 < Noosfero::Plugin
      def change_password_fields
        {:field => 'f1', :name => 'F1', :model => 'person'}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def change_password_fields
        [{:field => 'f2', :name => 'F2', :model => 'person'},
         {:field => 'f3', :name => 'F3', :model => 'person'}]
      end
    end

    environment = Environment.default
    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)
    person = create_user('testuser').person

    change_password = ChangePassword.new(:environment_id => environment.id)

    assert_includes change_password.fields, 'f1'
    assert_includes change_password.fields, 'f2'
    assert_includes change_password.fields, 'f3'
  end

end
