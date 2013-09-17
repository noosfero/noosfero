require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end

  should 'deliver activation email notify' do
    assert_difference ActionMailer::Base.deliveries, :size do
      u = create_user('some_user')
      User::Mailer.deliver_activation_email_notify(u)
    end
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end
