# encoding: UTF-8
require_relative "../test_helper"

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users, :environments

  def test_should_create_user
    assert_difference 'User.count' do
      user = new_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = new_user(:login => nil)
      assert u.errors[:login].present?
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = new_user(:password => nil)
      assert u.errors[:password].present?
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = new_user(:password_confirmation => nil)
      assert u.errors[:password_confirmation].present?
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = new_user(:email => nil)
      assert u.errors[:email].present?
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
    assert_equal users(:johndoe), User.authenticate('johndoe@localhost.localdomain', 'test')
    assert_equal nil, User.authenticate('wrongemail@localhost', 'test')
  end

  def test_should_authenticate_user_of_nondefault_environment
    assert_equal users(:other_ze), User.authenticate('ze', 'test', environments(:anhetegua_net))
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

    user = create_user('new_user', :email => 'new_user@example.com', :password => 'test', :password_confirmation => 'test')

    assert Person.exists?(['user_id = ?', user.id])

    assert_equal users_count + 1, User.count
    assert_equal person_count + 1, Person.count
  end

  def test_should_create_person_with_identifier_different_from_login
    user = User.create!(:login => 'new_user', :email => 'new_user@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:identifier => "new_test"})

    assert Person.exists?(['user_id = ?', user.id])

    assert user.login != user.person.identifier
  end

  def test_login_validation
    u = User.new
    u.valid?
    assert u.errors[:login.to_s].present?

    u.login = 'with space'
    u.valid?
    assert u.errors[:login.to_s].present?

    u.login = 'áéíóú'
    u.valid?
    assert u.errors[:login.to_s].present?

    u.login = 'rightformat2007'
    u.valid?
    assert ! u.errors[:login.to_s].present?

    u.login = 'rightformat'
    u.valid?
    assert ! u.errors[:login.to_s].present?

    u.login = 'right_format'
    u.valid?
    assert ! u.errors[:login.to_s].present?
  end

  def test_should_change_password
    user = create_user('changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_nothing_raised do
      user.change_password!('test', 'newpass', 'newpass')
    end
    assert !user.authenticated?('test')
    assert user.authenticated?('newpass')
  end

  def test_should_give_correct_current_password_for_changing_password
    user = create_user('changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_raise User::IncorrectPassword do
      user.change_password!('wrong', 'newpass', 'newpass')
    end
    assert !user.authenticated?('newpass')
    assert user.authenticated?('test')
  end

  should 'require matching confirmation when changing password by force' do
    user = create_user('changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_raise ActiveRecord::RecordInvalid do
      user.force_change_password!('newpass', 'newpasswrong')
    end
    assert !user.authenticated?('newpass')
    assert user.authenticated?('test')
  end

  should 'be able to force password change' do
    user = create_user('changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com')
    assert_nothing_raised  do
      user.force_change_password!('newpass', 'newpass')
    end
    assert user.authenticated?('newpass')
  end

  def test_should_create_person_when_creating_user
    count = Person.count
    assert !Person.find_by_identifier('lalala')
    new_user(:login => 'lalala', :email => 'lalala@example.com')
    assert Person.find_by_identifier('lalala')
  end

  should 'set the same environment for user and person objects' do
    env = fast_create(Environment)
    user = new_user(:environment_id => env.id)
    assert_equal env, user.environment
    assert_equal env, user.person.environment
  end

  def test_should_destroy_person_when_destroying_user
    user = new_user(:login => 'lalala', :email => 'lalala@example.com')
    assert Person.find_by_identifier('lalala')
    user.destroy
    assert !Person.find_by_identifier('lalala')
  end

  def test_should_encrypt_password_with_salted_sha1
    user = User.new(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test')
#TODO UPGRADE Leandro: I comment this code. The user model already create a person model
#    user.build_person(person_data)
    user.stubs(:salt).returns('testsalt')
    user.save!

    # SHA1+salt crypted form for password 'test', and salt 'testsalt',
    # calculated by hand at IRB
    crypted_password = '77606e8e9227f73618eefdfd36f8eb1b8b52ca5f'

    assert_equal crypted_password, user.crypted_password
  end

  def test_should_support_md5_passwords
    # ATTENTION this test explicitly exposes the crypted form of 'test'. This
    # makes 'test' a terrible password. :)
    user = new_user(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test', :password_type => 'md5')
    assert_equal '098f6bcd4621d373cade4e832627b4f6', user.crypted_password
  end


  def test_should_support_salted_md5_passwords
    user = new_user(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test', :password_type => 'salted_md5', :salt => 'test')
    assert_equal '05a671c66aefea124cc08b76ea6d30bb', user.crypted_password
  end

  def test_should_support_crypt_passwords
    user = new_user(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test', :password_type => 'crypt', :salt => 'test')
    assert_equal 'teH0wLIpW0gyQ', user.crypted_password
  end

  def test_should_support_clear_passwords
    assert_equal 'test', new_user(:password => 'test', :password_confirmation => 'test', :password_type => 'clear').crypted_password
  end

  def test_should_only_allow_know_encryption_methods
    assert_raise User::UnsupportedEncryptionType do
      User.create(
        :login => 'lalala',
        :email => 'lalala@example.com',
        :password => 'test',
        :password_confirmation => 'test',
        :password_type => 'AN_ENCRYPTION_METHOD_NOT_LIKELY_TO_EXIST' # <<<<
      )
    end
  end

  def test_should_use_salted_sha1_by_default
    assert_equal :salted_sha1, User.system_encryption_method
  end

  def test_should_be_able_to_set_system_encryption_method
    # save
    saved = User.system_encryption_method

    User.system_encryption_method = :some_method
    assert_equal :some_method, User.system_encryption_method

    # restore
    User.system_encryption_method = saved
  end

  def test_new_instances_should_use_system_encryption_method
    User.expects(:system_encryption_method).returns(:clear)
    assert_equal 'clear', new_user.password_type
  end

  def test_should_reencrypt_password_when_using_different_encryption_method_from_the_system_default
    User.stubs(:system_encryption_method).returns(:salted_sha1)

    # a user was created ...
    user = new_user(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test', :password_type => 'salted_sha1')

    # then the sysadmin decided to change the encryption method
    User.expects(:system_encryption_method).returns(:md5).at_least_once

    # when the user logs in, her password must be reencrypted with the new
    # method
    user.authenticated?('test')

    # and the new password must be saved back to the database
    user.reload
    assert_equal '098f6bcd4621d373cade4e832627b4f6', user.crypted_password
  end

  def test_should_not_update_encryption_if_password_incorrect
    # a user was created
    User.stubs(:system_encryption_method).returns(:salted_sha1)
    user = new_user(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test', :password_type => 'salted_sha1')
    crypted_password = user.crypted_password

    # then the sysadmin deciced to change the encryption method
    User.expects(:system_encryption_method).returns(:md5).at_least_once

    # but the user provided the wrong password
    user.authenticated?('WRONG_PASSWORD')

    # and then her password is not updated
    assert_equal crypted_password, user.crypted_password
  end

  def test_should_have_enable_email_setting
    u = User.new
    u.enable_email = true
    assert_equal true, u.enable_email
  end

  def test_should_have_enable_email_as_false_by_default
    assert_equal false, User.new.enable_email
  end

  should 'enable email' do
    user = create_user('cooler')
    assert !user.enable_email
    assert user.enable_email!
    assert user.enable_email
  end

  should 'has email activation pending' do
    user = create_user('cooler')
    user.update_attribute(:environment_id, Environment.default.id)
    EmailActivation.create!(:requestor => user.person, :target => Environment.default)
    assert user.email_activation_pending?
  end

  should 'not has email activation pending if not have environment' do
    user = create_user('cooler')
    user.expects(:environment).returns(nil).at_least_once
    EmailActivation.create!(:requestor => user.person, :target => Environment.default)
    assert !user.email_activation_pending?
  end

  should 'has moderate registration pending' do
    user = create_user('cooler')
    ModerateUserRegistration.create!(:requestor => user.person, :target => Environment.default)
    assert user.moderate_registration_pending?
  end

  should 'not has moderate registration pending if not have a pending task' do
    user = create_user('cooler')
    assert !user.moderate_registration_pending?
  end

  should 'be able to use [] operator to find users by login' do
    user = fast_create(User)
    assert_equal user, User[user.login]
  end

  should 'user has presence status to know when online or offline' do
    user = User.new
    assert_respond_to user, :chat_status
  end

  should 'remember last status from user' do
    user = User.new
    assert_respond_to user, :last_chat_status
  end

  should "have data_hash method defined" do
    user = fast_create(User)
    assert user.respond_to?(:data_hash)
  end

  should "data_hash method have at least the following keys" do
    user = create_user('coldplay')
    expected_keys = ['login','is_admin','since_month', 'since_year', 'email_domain','friends_list','amount_of_friends', 'enterprises', ]
    data = user.data_hash
    assert(expected_keys.all? { |k| data.has_key?(k) }, "User#data_hash expected to have at least the following keys: #{expected_keys.inspect} (missing: #{(expected_keys-data.keys).inspect})")
  end

  should "data_hash friends_list method have the following keys" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    expected_keys = ['avatar','name','jid','status']
    assert_equal [], expected_keys - person.user.data_hash['friends_list']['coldplayfriend'].keys
    assert_equal [], person.user.data_hash['friends_list']['coldplayfriend'].keys - expected_keys
  end

  should "data_hash method return the user information" do
    person = create_user('x_and_y').person
    Person.any_instance.stubs(:is_admin?).returns(true)
    Person.any_instance.stubs(:created_at).returns(DateTime.parse('16-08-2010'))
    expected_hash = {
      'login' => 'x_and_y', 'is_admin' => true, 'since_month' => 8,
      'chat_enabled' => false, 'since_year' => 2010, 'email_domain' => nil,
      'amount_of_friends' => 0, 'friends_list' => {}, 'enterprises' => [],
    }

    assert_equal expected_hash['login'], person.user.data_hash['login']
    assert_equal expected_hash['is_admin'], person.user.data_hash['is_admin']
    assert_equal expected_hash['since_month'], person.user.data_hash['since_month']
    assert_equal expected_hash['chat_enabled'], person.user.data_hash['chat_enabled']
    assert_equal expected_hash['since_year'], person.user.data_hash['since_year']

    # Avatar stuff
    assert_match '/www.gravatar.com/avatar/a0517761d5125820c28d87860bc7c02e', person.user.data_hash['avatar']
    assert_match 'only_path=false', person.user.data_hash['avatar']
    assert_match 'd=', person.user.data_hash['avatar']
    assert_match 'size=20', person.user.data_hash['avatar']

    assert_equal expected_hash['email_domain'], person.user.data_hash['email_domain']
    assert_equal expected_hash['amount_of_friends'], person.user.data_hash['amount_of_friends']
    assert_equal expected_hash['friends_list'], person.user.data_hash['friends_list']
  end

  should "data_hash return the friends_list information" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    Person.any_instance.stubs(:profile_custom_icon).returns('/custom_icon')
    expected_hash = {
      'coldplayfriend' => {
        'avatar' => '/custom_icon', 'name' => 'coldplayfriend', 'jid' => 'coldplayfriend@' + Environment.default.default_hostname + '/coldplayfriend', 'status' => 'chat'
      }
    }
    assert_equal expected_hash, person.user.data_hash['friends_list']
  end

  should "data_hash return the correct number of friends parameter" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    another_friend = create_user('coldplayanotherfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(another_friend)
    assert_equal 2, person.user.data_hash['amount_of_friends']
  end

  should "data_hash collect friend with online status and with presence in last 15 minutes" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    assert_equal 1, person.user.data_hash['amount_of_friends']
  end

  should "data_hash collect friend with busy status and with presence in last 15 minutes" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'dnd', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    assert_equal 1, person.user.data_hash['amount_of_friends']
  end

  should "data_hash status friend be described" do
    person = create_user('coldplay').person
    friend = create_user('coldplayfriend', :chat_status => 'chat', :chat_status_at => DateTime.now).person
    person.add_friend(friend)
    assert_equal 'chat', person.user.data_hash['friends_list'][friend.identifier]['status']
  end

  should 'return empty list of enterprises on data_hash for newly created user' do
    assert_equal [], create_user('testuser').data_hash['enterprises']
  end

  should 'return list of enterprises in data_hash' do
    user = create_user('testuser')
    enterprise = fast_create(Enterprise, :name => "My enterprise", :identifier => 'my-enterprise')
    user.person.expects(:enterprises).returns([enterprise])
    assert_includes user.data_hash['enterprises'], {'name' => 'My enterprise', 'identifier' => 'my-enterprise'}
  end

  should 'update chat status every 15 minutes' do
    assert_equal 15, User.expires_chat_status_every
  end

  should "return status of chat on environment in data_hash" do
    person = create_user('coldplay').person
    env = person.environment
    env.enable('xmpp_chat')
    env.save
    assert_equal true, person.user.data_hash['chat_enabled']

    env.disable('xmpp_chat')
    env.save
    person.reload
    assert_equal false, person.user.data_hash['chat_enabled']
  end

  should 'respond name with related person name' do
    user = create_user('testuser')
    user.person.name = 'Test User'
    assert_equal 'Test User', user.name
  end

  should 'respond name with login, if there is no person related and name defined' do
    user = create_user('testuser')
    user.person = nil
    user.name = nil
    assert_equal 'testuser', user.name
  end

  should 'respond name with user name attribute' do
    user = create_user('testuser')
    user.login = 'Login User'
    user.person = nil
    user.name = 'Another User'
    assert_equal 'Another User', user.name
  end

  should 'respond name with related person name although user name attribute is defined' do
    user = create_user('testuser')
    user.person.name = 'Person Name'
    user.name = 'Another User'
    user.login = 'Login User'
    assert_equal 'Person Name', user.name
  end

  should 'have activation code' do
    user = create_user('testuser')
    assert_respond_to user, :activation_code
  end

  should 'have activated at' do
    user = create_user('testuser')
    assert_respond_to user, :activated_at
  end

  should 'make activation code before creation' do
    assert_not_nil new_user.activation_code
  end

  should 'deliver e-mail with activation code after creation' do
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      new_user :email => 'pending@activation.com'
    end
    assert_equal 'pending@activation.com', ActionMailer::Base.deliveries.last['to'].to_s
  end

  should 'not try to deliver email to template users' do
    Person.any_instance.stubs(:is_template?).returns(true)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      new_user
    end
  end

  should 'authenticate an activated user' do
    user = new_user :login => 'testuser', :password => 'test123', :password_confirmation => 'test123'
    user.activate
    assert_equal user, User.authenticate('testuser', 'test123')
  end

  should 'not authenticate a not activated user' do
    user = new_user :login => 'testuser', :password => 'test123', :password_confirmation => 'test123'
    assert_nil User.authenticate('testuser', 'test123')
  end

  should 'have activation code but no activated at when created' do
    user = new_user
    assert_not_nil user.activation_code
    assert_nil user.activated_at
    assert !user.person.visible
  end

  should 'activate an user' do
    user = new_user
    assert user.activate
    assert_nil user.activation_code
    assert_not_nil user.activated_at
    assert user.person.visible
  end

  should 'return if the user is activated' do
    user = new_user
    assert !user.activated?
    user.activate
    assert user.activated?
  end

  should 'delay activation check with default time' do
    user = new_user
    job = Delayed::Job.last
    assert_match /UserActivationJob/, job.handler
    assert_equal 72, ((job.run_at - user.created_at)/1.hour).round
  end

  should 'delay activation check with custom time' do
    NOOSFERO_CONF.stubs(:[]).with('hours_until_user_activation_check').returns(240)
    NOOSFERO_CONF.stubs(:[]).with('exclude_profile_identifier_pattern')
    user = new_user
    job = Delayed::Job.last
    assert_match /UserActivationJob/, job.handler
    assert_equal 240, ((job.run_at - user.created_at)/1.hour).round
  end

  should 'not create job to check activation to template users' do
    Person.any_instance.stubs(:is_template?).returns(true)

    user = new_user
    assert_equal 0, Delayed::Job.by_handler("--- !ruby/struct:UserActivationJob\nuser_id: #{user.id}\n").count
  end

  should 'deactivate an user' do
    user = new_user
    user.activate
    assert user.deactivate
    assert_nil user.activated_at
    assert !user.person.visible
  end

  should 'return if the user is deactivated' do
    user = new_user
    user.activate
    assert user.activated?
    user.deactivate
    assert !user.activated?
  end

  should 'activate right after creation when confirmation is not required' do
    e = Environment.default
    e.enable('skip_new_user_email_confirmation')
    e.save!

    assert new_user.activated?
  end

  should 'cancel activation if user has no person associated' do
    user = new_user
    user.stubs(:person).returns(nil)
    assert !user.activate
  end

  should 'be able to skip the password requirement' do
    user = User.new(:login => 'quire', :email => 'quire@example.com')
    user.not_require_password!
    assert user.save!
  end

  should 'not deliver welcome e-mail after user activation if not enabled on environment' do
    env = Environment.default
    env.signup_welcome_text = {
      :subject => 'Welcome to the environment',
      :body => 'Thanks for signing up!'
    }
    env.disable('send_welcome_email_to_new_users')
    env.save

    user = new_user :email => 'pending@activation.com'
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      user.activate
    end
  end

  should 'deliver welcome e-mail after user activation if enabled on environment' do
    env = Environment.default
    env.signup_welcome_text = {
      :subject => 'Welcome to this environment',
      :body => 'Thanks for signing up!'
    }
    env.enable('send_welcome_email_to_new_users')
    env.save

    user = new_user :email => 'pending@activation.com'
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      user.activate
      process_delayed_job_queue
    end

    sent = ActionMailer::Base.deliveries.last
    assert_equal ['pending@activation.com'], sent.to
    assert_equal 'Welcome to this environment', sent.subject
    assert_match /Thanks for signing up!/, sent.body.to_s
  end

  should 'deliver welcome e-mail after user activation if enabled on environment with default subject if not defined' do
    env = Environment.default
    env.signup_welcome_text = {
      :body => 'Thanks for signing up!'
    }
    env.enable('send_welcome_email_to_new_users')
    env.save

    user = new_user :email => 'pending@activation.com'
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      user.activate
      process_delayed_job_queue
    end

    sent = ActionMailer::Base.deliveries.last
    assert_equal "Welcome to environment #{env.name}", sent.subject
  end

  should 'deliver welcome e-mail after user activation if enabled on environment and replace user_name' do
    env = Environment.default
    env.signup_welcome_text = {
      :subject => 'Welcome to the environment',
      :body => 'Thanks for signing up, {user_name}!',
    }
    env.enable('send_welcome_email_to_new_users')
    env.save

    user = new_user :name => 'John Doe', :email => 'pending@activation.com'
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      user.activate
      process_delayed_job_queue
    end

    sent = ActionMailer::Base.deliveries.last
    assert_match /Thanks for signing up, #{user.name}!/, sent.body.to_s
  end

  should 'not deliver welcome e-mail after user activation if enabled on environment but body not filled in' do
    env = Environment.default
    env.signup_welcome_text = {
      :subject => 'Welcome to the environment',
    }
    env.enable('send_welcome_email_to_new_users')
    env.save

    user = new_user :email => 'pending@activation.com'
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      user.activate
    end
  end

  should 'not deliver welcome e-mail after user activation if enabled on environment but welcome text not defined' do
    env = Environment.default
    env.enable('send_welcome_email_to_new_users')
    env.save

    user = new_user :email => 'pending@activation.com'
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      user.activate
    end
  end

  should 'create person with name equal to user name if a user name is defined' do
    user = User.new( :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' )
    user.name = "Some name"
    user.save
    assert_equal 'Some name', user.person.name
  end

  should 'create person with name equal to user login if no user name is defined' do
    user = User.new( :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' )
    user.save
    assert_equal 'quire', user.person.name
  end

  protected
    def new_user(options = {})
      user = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
      user.save
      user
    end
end
