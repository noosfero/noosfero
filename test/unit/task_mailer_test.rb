require_relative "../test_helper"

class TaskMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @environment = Environment.default
    @environment.noreply_email = 'noreply@example.com'
    @environment.stubs(:default_hostname).returns('example.com')
    @environment.name = 'example'

    Person.any_instance.stubs(:contact_email).returns('requestor@example.com')
    Person.any_instance.stubs(:public_profile_url).returns('requestor_path')
    @person = fast_create(Person, name: 'my nane')
  end
  attr_reader :environment, :person

  should 'be able to send a "task finished" message' do
    task = Task.new
    Task.any_instance.expects(:task_finished_message).returns('the message')
    Task.any_instance.expects(:target_notification_description).returns('the task')

    task.target = task.requestor = person

    task.save
    task.send(:send_notification, :finished)
    process_delayed_job_queue
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task cancelled" message' do
    task = Task.new
    Task.any_instance.expects(:task_cancelled_message).returns('the message')
    Task.any_instance.expects(:target_notification_description).returns('the task')
    task.target = task.requestor = person

    task.save
    task.send(:send_notification, :cancelled)
    process_delayed_job_queue
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "task created" message' do
    task = Task.new
    Task.any_instance.expects(:task_created_message).returns('the message')
    Task.any_instance.expects(:target_notification_description).returns('the task')
    task.target = task.requestor = person

    task.save
    process_delayed_job_queue
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "target notification" message' do
    requestor = fast_create(Person)
    requestor.expects(:notification_emails).returns(['requestor@example.com'])
    task = Task.new(:target => requestor)
    task.expects(:target_notification_description).returns('the task')

    TaskMailer.target_notification(task, 'the message').deliver
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'be able to send a "invitation notification" message' do

    task = InviteFriend.new
    task.expects(:code).returns('123456')
    task.target = task.requestor = person = Person.new
    person.environment = environment
    person.name = 'my name'
    person.stubs(:public_profile_url).returns('requestor_path')

    task.stubs(:message).returns('Hello <friend>, <user> invite you, please follow this link: <url>')
    task.expects(:friend_email).returns('friend@exemple.com')
    task.expects(:friend_name).returns('friend name').at_least_once

    mail = TaskMailer.invitation_notification(task)

    assert_match(/#{task.target_notification_description}/, mail.subject)

    assert_equal "Hello friend name, my name invite you, please follow this link: http://example.com/account/signup?invitation_code=123456", mail.body.to_s

    mail.deliver
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'use environment name and no-reply email' do
    task = mock
    task.expects(:environment).returns(environment).at_least_once

    assert_equal "#{environment.name} <#{environment.noreply_email}>", TaskMailer.generate_from(task)
  end

  should 'return the email with the subdirectory defined' do
    Noosfero.stubs(:root).returns('/subdir')

    task = InviteFriend.new
    task.expects(:code).returns('123456')
    task.target = task.requestor = person = Person.new
    person.environment = environment
    person.name = 'my name'
    person.stubs(:public_profile_url).returns('requestor_path')

    task.stubs(:message).returns('Hello <friend>, <user> invite you, please follow this link: <url>')
    task.expects(:friend_email).returns('friend@exemple.com')
    task.expects(:friend_name).returns('friend name').at_least_once

    mail = TaskMailer.invitation_notification(task)

    url_to_compare = "/subdir/account/signup"

    assert_match(/#{url_to_compare}/, mail.body.to_s)
  end

  should 'be able to send rejection notification based on a selected template' do
    task = Task.new
    task.reject_explanation = 'explanation'

    profile = fast_create(Community)
    email_template = EmailTemplate.create!(:owner => profile, :name => 'Template 1', :subject => 'template subject - {{environment.name}}', :body => 'template body - {{environment.name}} - {{task.requestor.name}} - {{task.reject_explanation}}')
    task.email_template_id = email_template.id

    requestor = Profile.new(:name => 'my name')
    requestor.expects(:notification_emails).returns(['requestor@example.com']).at_least_once

    Task.any_instance.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(@environment).at_least_once
    Task.any_instance.expects(:environment).returns(@environment).at_least_once
    Task.any_instance.expects(:task_cancelled_message).returns('the message')

    task.save
    task.send(:send_notification, :cancelled)
    process_delayed_job_queue
    assert !ActionMailer::Base.deliveries.empty?
    mail = ActionMailer::Base.deliveries.last
    assert_match /text\/html/, mail.content_type
    assert_equal 'template subject - example', mail.subject.to_s
    assert_equal 'template body - example - my name - explanation', mail.body.to_s
  end

  should 'be able to send accept notification based on a selected template' do
    task = Task.new
    Task.any_instance.expects(:task_finished_message).returns('the message')

    profile = fast_create(Community)
    email_template = EmailTemplate.create!(:owner => profile, :name => 'Template 1', :subject => 'template subject - {{environment.name}}', :body => 'template body - {{environment.name}} - {{task.requestor.name}}')
    task.email_template_id = email_template.id

    requestor = Profile.new(:name => 'my name')
    requestor.expects(:notification_emails).returns(['requestor@example.com']).at_least_once

    Task.any_instance.expects(:requestor).returns(requestor).at_least_once
    requestor.expects(:environment).returns(@environment).at_least_once
    Task.any_instance.expects(:environment).returns(@environment).at_least_once

    task.save
    task.send(:send_notification, :finished)
    process_delayed_job_queue
    assert !ActionMailer::Base.deliveries.empty?
    mail = ActionMailer::Base.deliveries.last
    assert_match /text\/html/, mail.content_type
    assert_equal 'template subject - example', mail.subject.to_s
    assert_equal 'template body - example - my name', mail.body.to_s
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/task_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
