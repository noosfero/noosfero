require File.dirname(__FILE__) + '/../test_helper'

class MailingTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.deliveries = []
    @environment = fast_create(Environment, :name => 'Network')
    create_user('user_one', :environment_id => @environment.id)
    create_user('user_two', :environment_id => @environment.id)
  end
  attr_reader :environment

  should 'source be able to polymorphic relationship' do
    m = Mailing.new
    assert_nothing_raised do
      m.source = Environment.new
    end
    assert_nothing_raised do
      m.source = Profile.new
    end
  end

  should 'require source_id' do
    mailing = Mailing.new
    mailing.valid?
    assert mailing.errors.invalid?(:source_id)

    mailing.source_id = Environment.default.id
    mailing.valid?
    assert !mailing.errors.invalid?(:source_id)
  end

  should 'require subject' do
    mailing = Mailing.new
    mailing.valid?
    assert mailing.errors.invalid?(:subject)

    mailing.subject = 'Hello :)'
    mailing.valid?
    assert !mailing.errors.invalid?(:subject)
  end

  should 'require body' do
    mailing = Mailing.new
    mailing.valid?
    assert mailing.errors.invalid?(:body)

    mailing.body = 'We have some news!'
    mailing.valid?
    assert !mailing.errors.invalid?(:body)
  end

  should 'return source' do
    mailing = Mailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news')
    assert_equal environment, Mailing.find(mailing.id).source
  end

  should 'return source name' do
    mailing = Mailing.new(:source => environment)
    assert_equal environment.name, mailing.source.name
  end

  should 'return source with source_id' do
    mailing = Mailing.new(:source => environment)
    assert_equal environment, mailing.source
  end

  should 'return person with person_id' do
    person = Person['user_one']
    mailing = Mailing.new(:source => environment, :person => person)
    assert_equal person, mailing.person
  end

  should 'display name and email on generate_from' do
    person = Person['user_one']
    mailing = Mailing.new(:source => environment, :person => person)
    assert_equal "#{environment.name} <#{environment.contact_email}>", mailing.generate_from
  end

  should 'generate subject' do
    mailing = Mailing.new(:source => environment, :subject => 'Hello :)')
    assert_equal "[#{environment.name}] #{mailing.subject}", mailing.generate_subject
  end

  should 'return signature message' do
    mailing = Mailing.new(:source => environment)
    assert_equal 'Sent by Noosfero.', mailing.signature_message
  end

  should 'return blank string on url' do
    mailing = Mailing.new(:source => environment)
    environment.domains << Domain.create(:name => 'noosfero.net', :is_default => true)
    assert_equal '', mailing.url
  end

  should 'deliver mailing to each recipient after create' do
    person = Person['user_one']
    mailing = Mailing.create(:source => environment, :subject => 'Hello', :body => 'We have some news', :person => person)
    process_delayed_job_queue
    assert_equal [], ActionMailer::Base.deliveries
  end
end
