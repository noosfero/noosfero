require 'test_helper'

class EnvironmentNotificationHelperTest < ActiveSupport::TestCase
  def setup
    @env = Environment.default
    @env.enable_plugin('EnvironmentNotificationPlugin')

    @user = User.create!(:environment_id => @env.id, :email => "user@domain.com", :login   => "new_user", :password => "test", :password_confirmation => "test", :name => "UserName")
  end

  should 'substitute all email variables to the current user email' do
    message = "Hello user with email %{email}! please, update your current email (%{email})."

    new_message = EnvironmentNotificationHelper.substitute_variables(message, @user)

    assert message != new_message
    assert_equal new_message, "Hello user with email user@domain.com! please, update your current email (user@domain.com)."
  end

  should 'not substitute emails variables if there is no current user' do
    message = "Hello user with email %{email}! please, update your current email (%{email})."

    new_message = EnvironmentNotificationHelper.substitute_variables(message, nil)

    assert_equal message, new_message
    assert_not_includes new_message, "user@domain.com"
  end

   should 'substitute all name variables to the current user name' do
    message = "Hello %{name}! is %{name} your real name?."

    new_message = EnvironmentNotificationHelper.substitute_variables(message, @user)

    assert message != new_message
    assert_equal new_message, "Hello UserName! is UserName your real name?."
  end

  should 'not substitute name variables if there is no current user' do
    message = "Hello %{name}! is %{name} your real name?."

    new_message = EnvironmentNotificationHelper.substitute_variables(message, nil)

    assert_equal message, new_message
    assert_not_includes new_message, "UserName"
  end
end
