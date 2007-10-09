require File.dirname(__FILE__) + '/../test_helper'

class ChangePasswordTest < Test::Unit::TestCase

  fixtures :environments

  should 'validate' do
    data = ChangePassword.new
    assert !data.valid?
  end
  
  should 'refuse invalid username' do
    User.destroy_all

    data = ChangePassword.new
    data.login = 'unexisting'
    data.valid?
    assert data.errors.invalid?(:login)
  end

  should 'require a valid username' do
    User.destroy_all
    User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.valid?
    assert !data.errors.invalid?(:login)
  end

  should 'refuse incorrect e-mail address' do
    User.destroy_all
    User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.email = 'wrong@example.com'

    data.valid?
    assert !data.errors.invalid?(:login)
    assert data.errors.invalid?(:email)
  end

  should 'require the correct e-mail address' do
    User.destroy_all
    User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    data = ChangePassword.new
    data.login = 'testuser'
    data.email = 'test@example.com'

    data.valid?
    assert !data.errors.invalid?(:login)
    assert !data.errors.invalid?(:email)
  end

  should 'require correct passsword confirmation' do
    User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    change = ChangePassword.new
    change.login = 'testuser'
    change.email = 'test@example.com'
    change.save!

    change.password = 'right'
    change.password_confirmation = 'wrong'
    assert !change.valid?
    assert change.errors.invalid?(:password)


    change.password_confirmation = 'right'
    assert change.valid?
  end

  should 'actually change password' do
    User.destroy_all
    User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')

    change = ChangePassword.new
    change.login = 'testuser'
    change.email = 'test@example.com'
    change.save!

    user = User.new
    User.expects(:find_by_login).with('testuser').returns(user)
    user.expects(:force_change_password!).with('newpass', 'newpass')

    change.password = 'newpass'
    change.password_confirmation = 'newpass'
    change.finish

  end

end
