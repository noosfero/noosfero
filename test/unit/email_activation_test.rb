require File.dirname(__FILE__) + '/../test_helper'

class EmailActivationTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  should 'require a requestor' do
    task = EmailActivation.new
    task.valid?

    assert task.errors.invalid?(:requestor_id)
  end

  should 'require a target (environment)' do
    task = EmailActivation.new
    task.valid?

    assert task.errors.invalid?(:target_id)
  end

  should 'enable user email when finish' do
    ze = create_user('zezinho', :environment_id => Environment.default.id)
    assert !ze.enable_email
    task = fast_create(EmailActivation, :requestor_id => ze.person.id, :target_id => Environment.default.id)
    task.finish
    ze.reload
    assert ze.enable_email
  end

  should 'deliver email after enabling mailbox' do
    ze = create_user('zezinho', :environment_id => Environment.default.id, :email => 'ze@example.com')
    assert !ze.enable_email
    task = EmailActivation.create!(:requestor => ze.person, :target => Environment.default)
    task.finish

    assert_equal ["zezinho@#{ze.email_domain}"], ActionMailer::Base.deliveries.first.to
  end

  should 'create only once pending task by user' do
    ze = create_user('zezinho', :environment_id => Environment.default.id)
    task = EmailActivation.new(:requestor => ze.person, :target => Environment.default)
    assert task.save!

    anothertask = EmailActivation.new(:requestor => ze.person, :target => Environment.default)
    assert !anothertask.save
  end

  should 'deliver activation email notification' do
    user = create_user('testuser', :environment_id => Environment.default.id)

    task = EmailActivation.new(:requestor => user.person, :target => Environment.default)

    email = User::Mailer.deliver_activation_email_notify(user)
    assert_match(/Welcome to #{task.requestor.environment.name} mail!/, email.subject)
  end

end
