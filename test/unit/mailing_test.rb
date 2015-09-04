require_relative "../test_helper"

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
    assert mailing.errors[:source_id.to_s].present?

    mailing.source_id = Environment.default.id
    mailing.valid?
    refute mailing.errors[:source_id.to_s].present?
  end

  should 'require subject' do
    mailing = Mailing.new
    mailing.valid?
    assert mailing.errors[:subject.to_s].present?

    mailing.subject = 'Hello :)'
    mailing.valid?
    refute mailing.errors[:subject.to_s].present?
  end

  should 'require body' do
    mailing = Mailing.new
    mailing.valid?
    assert mailing.errors[:body.to_s].present?

    mailing.body = 'We have some news!'
    mailing.valid?
    refute mailing.errors[:body.to_s].present?
  end

  should 'return source' do
    mailing = create(Mailing, :source => environment, :subject => 'Hello', :body => 'We have some news')
    assert_equal environment, Mailing.find(mailing.id).source
  end

  should 'return source name' do
    mailing = build(Mailing, :source => environment)
    assert_equal environment.name, mailing.source.name
  end

  should 'return source with source_id' do
    mailing = build(Mailing, :source => environment)
    assert_equal environment, mailing.source
  end

  should 'return person with person_id' do
    person = Person['user_one']
    mailing = build(Mailing, :source => environment, :person => person)
    assert_equal person, mailing.person
  end

  should 'display name and email on generate_from' do
    person = Person['user_one']
    mailing = build(Mailing, :source => environment, :person => person)
    assert_equal "#{environment.name} <#{environment.noreply_email}>", mailing.generate_from
  end

  should 'generate subject' do
    mailing = build(Mailing, :source => environment, :subject => 'Hello :)')
    assert_equal "[#{environment.name}] #{mailing.subject}", mailing.generate_subject
  end

  should 'return signature message' do
    mailing = build(Mailing, :source => environment)
    assert_equal 'Sent by Noosfero.', mailing.signature_message
  end

  should 'return blank string on url' do
    mailing = build(Mailing, :source => environment)
    environment.domains << create(Domain, :name => 'noosfero.net', :is_default => true)
    assert_equal '', mailing.url
  end

  should 'process the entire batch even if individual emails crash' do
    mailing = build(Mailing, :source => environment, :person => Person['user_one'], :body => 'test', :subject => 'test')
    def mailing.each_recipient
      user_one = Person['user_one']
      user_two = Person['user_two']
      user_one.stubs(:email).raises(RuntimeError.new)
      [user_one, user_two].each do |p|
        yield p
      end
    end
    mailing.stubs(:schedule)
    mailing.save!
    mailing.deliver

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

end
