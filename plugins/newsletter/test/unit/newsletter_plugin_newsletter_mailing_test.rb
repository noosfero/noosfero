require 'test_helper'

class NewsletterPluginNewsletterMailingTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  should 'require source id' do
    mailing = NewsletterPlugin::NewsletterMailing.new
    mailing.valid?
    assert mailing.errors[:source_id].any?

    mailing.source_id = NewsletterPlugin::Newsletter.create!(:environment => fast_create(Environment), :person => fast_create(Person)).id
    mailing.valid?
    refute mailing.errors[:source_id].any?
  end

  should 'deliver mail from noreply environment email address' do
    environment = fast_create(Environment, :noreply_email => 'noreply@localhost')
    person = fast_create Person
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => person, :enabled => true)
    mailing = NewsletterPlugin::NewsletterMailing.create!(
      :source => newsletter,
      :subject => newsletter.subject,
      :body => newsletter.body,
      :person => newsletter.person,
      :locale => environment.default_locale,
    )
    response = NewsletterPlugin::NewsletterMailing::Sender.notification(mailing, 'recipient@example.com').deliver
    assert_equal 'noreply@localhost', response.from.join
  end

  should 'also send to additional recipients' do
    environment = fast_create(Environment, :name => 'Network')
    person = create_user('betty', :environment_id => environment.id).person
    newsletter = NewsletterPlugin::Newsletter.create!(:environment => environment, :person => person)

    newsletter.additional_recipients = [{name: 'example', email: 'exemple@mail.co'}, {name: 'jon', email: 'jonsnow@mail.co'}]
    newsletter.save!

    mailing = NewsletterPlugin::NewsletterMailing.create!(
      :source => newsletter,
      :subject => newsletter.subject,
      :body => newsletter.body,
      :person => newsletter.person,
      :locale => newsletter.environment.default_locale,
    )

    process_delayed_job_queue
    assert_equal 3, ActionMailer::Base.deliveries.count
  end

  should 'generate url to view mailing' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person),
      :enabled => true
    )
    mailing = NewsletterPlugin::NewsletterMailing.create!(
      :source => newsletter,
      :subject => newsletter.subject,
      :body => newsletter.body,
      :person => newsletter.person,
      :locale => newsletter.environment.default_locale,
    )
    assert_equal "http://localhost/plugin/newsletter/mailing/#{mailing.id}", mailing.url
  end

end
