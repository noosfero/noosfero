require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:johndoe).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:johndoe), User.authenticate('johndoe', 'new password')
  end

  def test_should_not_rehash_password
    users(:johndoe).update_attributes(:login => 'johndoe2')
    assert_equal users(:johndoe), User.authenticate('johndoe2', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:johndoe), User.authenticate('johndoe', 'test')
  end

  def test_should_set_remember_token
    users(:johndoe).remember_me
    assert_not_nil users(:johndoe).remember_token
    assert_not_nil users(:johndoe).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:johndoe).remember_me
    assert_not_nil users(:johndoe).remember_token
    users(:johndoe).forget_me
    assert_nil users(:johndoe).remember_token
  end

  def test_should_create_person
    users_count = User.count
    person_count = Person.count

    user = User.create!(:login => 'new_user', :email => 'new_user@example.com', :password => 'test', :password_confirmation => 'test')

    assert Person.exists?(['user_id = ?', user.id])

    assert_equal users_count + 1, User.count
    assert_equal person_count + 1, Person.count
  end

  def test_login_validation
    u = User.new
    u.valid?
    assert u.errors.invalid?(:login)

    u.login = 'with space'
    u.valid?
    assert u.errors.invalid?(:login)

    u.login = 'áéíóú'
    u.valid?
    assert u.errors.invalid?(:login)

    u.login = 'rightformat2007'
    u.valid?
    assert ! u.errors.invalid?(:login)

    u.login = 'rightformat'
    u.valid?
    assert ! u.errors.invalid?(:login)

    u.login = 'right_format'
    u.valid?
    assert ! u.errors.invalid?(:login)
  end

  def test_should_change_password
    user = User.create!(:login => 'changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_nothing_raised do
      user.change_password!('test', 'newpass', 'newpass')
    end
    assert !user.authenticated?('test')
    assert user.authenticated?('newpass')
  end

  def test_should_give_correct_current_password_for_changing_password
    user = User.create!(:login => 'changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_raise User::IncorrectPassword do
      user.change_password!('wrong', 'newpass', 'newpass')
    end
    assert !user.authenticated?('newpass')
    assert user.authenticated?('test')
  end

  should 'require matching confirmation when changing password by force' do
    user = User.create!(:login => 'changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_raise ActiveRecord::RecordInvalid do
      user.force_change_password!('newpass', 'newpasswrong')
    end
    assert !user.authenticated?('newpass')
    assert user.authenticated?('test')
  end

  should 'be able to force password change' do
    user = User.create!(:login => 'changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_nothing_raised  do
      user.force_change_password!('newpass', 'newpass')
    end
    assert user.authenticated?('newpass')
  end

  def test_should_create_person_when_creating_user
    count = Person.count
    assert !Person.find_by_identifier('lalala')
    create_user(:login => 'lalala', :email => 'lalala@example.com')
    assert Person.find_by_identifier('lalala')
  end

  def test_should_destroy_person_when_destroying_user
    user = create_user(:login => 'lalala', :email => 'lalala@example.com')
    assert Person.find_by_identifier('lalala')
    user.destroy
    assert !Person.find_by_identifier('lalala')
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
