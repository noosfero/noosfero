require_relative "../test_helper"

class PendingTaskNotifierTest < ActiveSupport::TestCase
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
    response = PendingTaskNotifier.notification(p).deliver
    assert_equal "[#{env.name}] Pending tasks", response.subject
    assert_equal p.email, response.to[0]
  end

  should 'list organization pending tasks' do
    p = create_user('maelcum').person
    c = fast_create(Community)
    c.add_admin(p)
    c.tasks << Task.new(:requestor => p)

    response = PendingTaskNotifier.notification(p).deliver
    assert_match /sent you a task/, response.body.to_s
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end
