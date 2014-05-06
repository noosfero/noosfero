require 'test_helper'

class SpaminatorPlugin::MailerTest < ActiveSupport::TestCase
  CHARSET = "utf-8"

  def setup
    Noosfero::Plugin::MailerBase.delivery_method = :test
    Noosfero::Plugin::MailerBase.perform_deliveries = true
    Noosfero::Plugin::MailerBase.deliveries = []
    @environment = Environment.default
    @settings = Noosfero::Plugin::Settings.new(@environment, SpaminatorPlugin)
  end

  attr_accessor :environment, :settings

  should 'be able to send a inactive person notification message' do
    environment.noreply_email = 'no-reply@noosfero.org'
    environment.save

    person = create_user('spammer').person
    mail = SpaminatorPlugin::Mailer.inactive_person_notification(person).deliver

    assert_equal ['spammer@noosfero.org'], mail.to
    assert_equal ['no-reply@noosfero.org'], mail.from
    assert_match(/You must reactivate your account/, mail.subject)
  end
end
