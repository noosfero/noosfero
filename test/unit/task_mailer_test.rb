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
    requestor.expects(:notification_emails).returns(['requestor@example.com'])
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_finished(task)
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task cancelled" message' do

    task = Task.new
    task.expects(:task_cancelled_message).returns('the message')
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:notification_emails).returns(['requestor@example.com'])
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_cancelled(task)
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task created" message' do

    task = Task.new

    task.expects(:task_created_message).returns('the message')
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:notification_emails).returns(['requestor@example.com'])
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_task_created(task)
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "target notification" message' do
    task = Task.new
    task.expects(:description).returns('the task')

    requestor = mock()
    requestor.expects(:name).returns('my name')

    target = mock()
    target.expects(:notification_emails).returns(['target@example.com'])
    target.expects(:name).returns('Target')
    target.expects(:url).returns({:host => 'my.domain.com', :profile => 'testprofile'})

    environment = mock()
    environment.expects(:contact_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    task.expects(:target).returns(target).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    TaskMailer.deliver_target_notification(task, 'the message')
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'use environment name and contact email' do
    task = mock
    requestor = mock
    environment = mock
    environment.expects(:name).returns('My name')
    environment.expects(:contact_email).returns('email@example.com')

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once

    assert_equal 'My name <email@example.com>', TaskMailer.generate_from(task)
  end


  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/task_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
