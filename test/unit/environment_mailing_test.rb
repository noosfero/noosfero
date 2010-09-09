require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentMailingTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @environment = fast_create(Environment, :name => 'Network')
    create_user('user_one', :environment_id => @environment.id)
    create_user('user_two', :environment_id => @environment.id)
  end
  attr_reader :environment


  should 'require source_id' do
    mailing = EnvironmentMailing.new
    mailing.valid?
    assert mailing.errors.invalid?(:source_id)

    mailing.source_id = environment.id
    mailing.valid?
    assert !mailing.errors.invalid?(:source_id)
  end

  should 'return environment name' do
    mailing = EnvironmentMailing.new(:source => environment)
    assert_equal environment.name, mailing.source.name
  end

  should 'return environment with source_id' do
    mailing = EnvironmentMailing.new(:source => environment)
    assert_equal environment, mailing.source
  end

  should 'return signature message' do
    mailing = EnvironmentMailing.new(:source => environment)
    assert_equal 'Sent by Noosfero Network.', mailing.signature_message
  end

  should 'return url for environment on url' do
    mailing = EnvironmentMailing.new(:source => environment)
    environment.domains << Domain.create(:name => 'noosfero.net', :is_default => true)
    assert_equal 'http://noosfero.net', mailing.url
  end

  should 'display name and email on generate_from' do
    person = Person['user_one']
    mailing = EnvironmentMailing.new(:source => environment, :person => person)
    assert_equal "#{environment.name} <#{environment.contact_email}>", mailing.generate_from
  end

  should 'deliver mailing to each recipient after create' do
    person = Person['user_one']
    mailing = EnvironmentMailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :person => person)
    process_delayed_job_queue
    assert_equal 2, ActionMailer::Base.deliveries.count
  end

  should 'create mailing sent to each recipient after delivering mailing' do
    person = Person['user_one']
    mailing = EnvironmentMailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :person => person)
    assert_difference MailingSent, :count, 2 do
      process_delayed_job_queue
    end
  end

  should 'change locale according to the mailing locale' do
    person = Person['user_one']
    mailing = EnvironmentMailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :locale => 'pt', :person => person)
    Noosfero.expects(:with_locale).with('pt')
    process_delayed_job_queue
  end

  should 'return recipient' do
    mailing = EnvironmentMailing.new(:source => environment)
    assert_equal Person['user_one'], mailing.recipient
  end

  should 'return true if already sent mailing to a recipient' do
    person = Person['user_one']
    mailing = EnvironmentMailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :person => person)
    process_delayed_job_queue

    assert mailing.already_sent_mailing_to?(person)
  end

  should 'return false if did not sent mailing to a recipient' do
    recipient = fast_create(Person)
    person = Person['user_one']
    mailing = EnvironmentMailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :person => person)
    process_delayed_job_queue

    assert !mailing.already_sent_mailing_to?(recipient)
  end

end
