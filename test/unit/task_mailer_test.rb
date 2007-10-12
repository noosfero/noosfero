require File.dirname(__FILE__) + '/../test_helper'

class TaskMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  should 'be able to send a "task finished" message' do

    task = Task.new
    task.expects(:task_finished_message).returns('the message')
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:email).returns('requestor@example.com')
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example')

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_finished(task)
  end

  should 'be able to send a "task cancelled" message' do

    task = Task.new
    task.expects(:task_cancelled_message).returns('the message')
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:email).returns('requestor@example.com')
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example')

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_cancelled(task)
  end

  should 'be able to send a "task created" message' do

    task = Task.new

    task.expects(:task_created_message).returns('the message')
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:email).returns('requestor@example.com')
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example')

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_created(task)
  end


  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/task_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
