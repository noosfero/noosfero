require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end


  should 'deliver activation email notify' do
    assert_difference ActionMailer::Base.deliveries, :size do
      u = Person.find(:first).user
      u.environment = Environment.default
      User::Mailer.deliver_activation_email_notify(u)
    end
  end

  should 'deliver notify when activate email' do
    u = Person.find(:first).user
    u.environment = Environment.default
    u.enable_email = false
    u.save!
    assert_difference ActionMailer::Base.deliveries, :size do
      u.enable_email = true
      u.save!
    end
  end

  should 'not deliver notify when disactivate email' do
    u = Person.find(:first).user
    u.environment = Environment.default
    u.enable_email = true
    u.save!
    assert_no_difference ActionMailer::Base.deliveries, :size do
      u.enable_email = false
      u.save!
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
