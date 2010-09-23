require File.dirname(__FILE__) + '/../test_helper'

class ScrapNotifierTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @sender = create_user('user_scrap_sender_test').person
    @receiver = create_user('user_scrap_receiver_test').person
  end

  should 'deliver mail after leave scrap' do
    assert_difference ActionMailer::Base.deliveries, :size do
      Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    end
  end

  should 'deliver mail even if it is a reply' do
    s = Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    assert_difference ActionMailer::Base.deliveries, :size do
      s.replies << Scrap.new(:sender => @sender, :receiver => @receiver, :content => 'Hi again man!')
    end
  end

  should 'deliver mail to receiver of the scrap' do
    Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@receiver.email], sent.to
  end

  should 'display sender name in delivered mail' do
    Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /user_scrap_sender_test/, sent.body
  end

  should 'display scrap content in delivered mail' do
    Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /Hi man!/, sent.body
  end

  should 'display receiver wall link in delivered mail' do
    Scrap.create!(:sender => @sender, :receiver => @receiver, :content => 'Hi man!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /\/profile\/user_scrap_receiver_test#profile-wall/, sent.body
  end

  should 'not deliver mail if notify receiver and sender are the same person' do
    assert_no_difference ActionMailer::Base.deliveries, :size do
      Scrap.create!(:sender => @sender, :receiver => @sender, :content => 'Hi myself!')
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
