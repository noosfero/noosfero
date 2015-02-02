require_relative "../test_helper"

class TaskMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end

  should 'be able to send a "task finished" message' do

    task = Task.new
    task.expects(:task_finished_message).returns('the message')
    task.expects(:target_notification_description).returns('the task')

    requestor = mock()
    requestor.expects(:notification_emails).returns(['requestor@example.com']).at_least_once
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:noreply_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once
    task.expects(:environment).returns(environment).at_least_once

    task.send(:send_notification, :finished).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task cancelled" message' do

    task = Task.new
    task.expects(:task_cancelled_message).returns('the message')
    task.expects(:target_notification_description).returns('the task')

    requestor = mock()
    requestor.expects(:notification_emails).returns(['requestor@example.com']).at_least_once
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:noreply_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once
    task.expects(:environment).returns(environment).at_least_once

    task.send(:send_notification, :cancelled).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task created" message' do

    task = Task.new

    task.expects(:task_created_message).returns('the message')
    task.expects(:target_notification_description).returns('the task')

    requestor = mock()
    requestor.expects(:notification_emails).returns(['requestor@example.com']).at_least_once
    requestor.expects(:name).returns('my name')

    environment = mock()
    environment.expects(:noreply_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once
    task.expects(:environment).returns(environment).at_least_once

    task.send(:send_notification, :created).deliver
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "target notification" message' do
    requestor = fast_create(Person)
    requestor.expects(:notification_emails).returns(['requestor@example.com'])
    task = Task.new(:target => requestor)
    task.expects(:target_notification_description).returns('the task')

    TaskMailer.target_notification(task, 'the message').deliver
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "invitation notification" message' do

    task = InviteFriend.new
    task.expects(:code).returns('123456')

    task.stubs(:message).returns('Hello <friend>, <user> invite you, please follow this link: <url>')
    task.expects(:friend_email).returns('friend@exemple.com')
    task.expects(:friend_name).returns('friend name').at_least_once

    requestor = mock()
    requestor.stubs(:name).returns('my name')
    requestor.stubs(:public_profile_url).returns('requestor_path')

    environment = mock()
    environment.expects(:noreply_email).returns('sender@example.com')
    environment.expects(:default_hostname).returns('example.com')
    environment.expects(:name).returns('example').at_least_once

    task.expects(:requestor).returns(requestor).at_least_once
    task.expects(:person).returns(requestor).at_least_once
    requestor.expects(:environment).returns(environment).at_least_once
    task.expects(:environment).returns(environment).at_least_once

    mail = TaskMailer.invitation_notification(task)

    assert_match(/#{task.target_notification_description}/, mail.subject)

    assert_equal "Hello friend name, my name invite you, please follow this link: http://example.com/account/signup?invitation_code=123456", mail.body.to_s
    
    mail.deliver
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'use environment name and no-reply email' do
    task = mock
    environment = mock
    environment.expects(:name).returns('My name')
    environment.expects(:noreply_email).returns('email@example.com')

    task.expects(:environment).returns(environment).at_least_once

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
