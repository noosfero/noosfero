require_relative "../test_helper"

class EnvironmentMailingTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @environment = fast_create(Environment, :name => 'Network')
    @person_1 = create_user('user_one', :environment_id => @environment.id).person
    @person_2 = create_user('user_two', :environment_id => @environment.id).person
  end
  attr_reader :environment, :person_1, :person_2


  should 'require source_id' do
    mailing = EnvironmentMailing.new
    mailing.valid?
    assert mailing.errors[:source_id].any?

    mailing.source_id = environment.id
    mailing.valid?
    refute mailing.errors[:source_id].any?
  end

  should 'return environment name' do
    mailing = new_mailing(environment)
    assert_equal environment.name, mailing.source.name
  end

  should 'return environment with source_id' do
    mailing = new_mailing(environment)
    assert_equal environment, mailing.source
  end

  should 'return signature message' do
    mailing = new_mailing(environment)
    assert_equal 'Sent by Network.', mailing.signature_message
  end

  should 'return url for environment on url' do
    mailing = new_mailing(environment)
    domain = Domain.new(:name => 'noosfero.net')
    domain.is_default = true
    environment.domains << domain
    assert_equal 'http://noosfero.net', mailing.url
  end

  should 'display name and email on generate_from' do
    mailing = new_mailing(environment).tap do |m|
      m.person = person_1
    end
    assert_equal "#{environment.name} <#{environment.noreply_email}>", mailing.generate_from
  end

  should 'deliver mailing to each recipient after create' do
    mailing = create_mailing(environment, :person => person_1)
    process_delayed_job_queue
    assert_equal 2, ActionMailer::Base.deliveries.count
  end

  should 'create mailing sent to each recipient after delivering mailing' do
    mailing = create_mailing(environment, :person => person_1)
    assert_difference 'MailingSent.count', 2 do
      process_delayed_job_queue
    end
  end

  should 'change locale according to the mailing locale' do
    mailing = create_mailing(environment, :locale => 'pt', :person => person_1)
    Noosfero.expects(:with_locale).with('pt')
    process_delayed_job_queue
  end

  should 'return recipients' do
    mailing = create_mailing(environment, :locale => 'pt', :person => person_1)
    assert_equal [person_1, person_2], mailing.recipients
  end

  should 'return recipients according to limit' do
    mailing = create_mailing(environment, :locale => 'pt', :person => person_1)
    assert_equal [person_1], mailing.recipients(0, 1)
  end

  should 'return true if already sent mailing to a recipient' do
    mailing = create_mailing(environment, :person => person_1)
    process_delayed_job_queue

    assert mailing.mailing_sents.find_by_person_id(person_1.id)
  end

  should 'return false if did not sent mailing to a recipient' do
    recipient = fast_create(Person)
    person = Person['user_one']
    mailing = create_mailing(environment, :person => person_1)
    process_delayed_job_queue

    refute mailing.mailing_sents.find_by_person_id(recipient.id)
  end

  def new_mailing(environment)
    m = EnvironmentMailing.new(:subject => 'Hello', :body => 'We have some news')
    m.source = environment
    m
  end

  def create_mailing(environment, options)
    new_mailing(environment).tap do |m|
      m.locale = options[:locale]
      m.person = options[:person]
      m.save!
    end
  end

end
