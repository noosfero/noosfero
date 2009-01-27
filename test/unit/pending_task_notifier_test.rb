require File.dirname(__FILE__) + '/../test_helper'

class PendingTaskNotifierTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end

  should 'be able to deliver notification' do
    env = Environment.default
    p = create_user('maelcum').person
    response = PendingTaskNotifier.deliver_notification(p)
    assert_equal "[#{env.name}] Pending tasks", response.subject
    assert_equal p.email, response.to[0]
  end

  should 'list organization pending tasks' do
    p = create_user('maelcum').person
    c = Community.create!(:name => 'my test community')
    c.add_admin(p)
    c.tasks << Task.new

    response = PendingTaskNotifier.deliver_notification(p)
    assert_match /Generic task/, response.body
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end
