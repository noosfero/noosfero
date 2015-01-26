require_relative "../test_helper"

class UserMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end

  should 'deliver activation email notify' do
    assert_difference 'ActionMailer::Base.deliveries.size' do
      u = create_user('some-user')
      UserMailer.activation_email_notify(u).deliver
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
