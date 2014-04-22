require File.dirname(__FILE__) + '/../test_helper'

class PersonNotifierTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    Person.destroy_all
    @admin = create_user('adminuser').person
    @member = create_user('member').person
    @admin.notification_time = 24
    @member.notification_time = 24
    @admin.save!
    @member.save!
    @community = fast_create(Community)
    @community.add_member(@admin)
    @article = fast_create(TextileArticle, :name => 'Article test', :profile_id => @community.id, :notify_comments => false)
    Delayed::Job.delete_all
    notify
    ActionMailer::Base.deliveries = []
  end

  should 'deliver mail to community members' do
    @community.add_member(@member)
    process_delayed_job_queue
    notify
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@member.email], sent.to
  end

  should 'do not send mail if do not have notifications' do
    @community.add_member(@member)
    ActionTracker::Record.delete_all
    assert_no_difference ActionMailer::Base.deliveries, :count do
      notify
    end
  end

  should 'do not send mail to people not joined to community' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    assert_no_difference ActionMailer::Base.deliveries, :count do
      notify
    end
  end

  should 'display author name in delivered mail' do
    @community.add_member(@member)
    Comment.create!(:author => @admin, :title => 'test comment', :body => 'body!', :source => @article)
    process_delayed_job_queue
    notify
    sent = ActionMailer::Base.deliveries.last
    assert_match /#{@admin.name}/, sent.body
  end

  should 'do not include comment created before last notification' do
    @community.add_member(@member)
    ActionTracker::Record.delete_all
    comment = Comment.create!(:author => @admin, :title => 'test comment', :body => 'body!', :source => @article )
    @member.last_notification = DateTime.now + 1.day
    assert_no_difference ActionMailer::Base.deliveries, :count do
      notify
    end
  end

  should 'update last notification date' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    @community.add_member(@member)
    initial_notification = @member.last_notification
    notify
    assert @member.last_notification > initial_notification
  end

  should 'reschedule after notification' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    @community.add_member(@member)
    assert PersonNotifier::NotifyJob.find(@member.id).blank?
    notify
    assert PersonNotifier::NotifyJob.find(@member.id)
  end

  should 'schedule next mail at notification time' do
    @member.notification_time = 12
    time = Time.now
    @member.notifier.schedule_next_notification_mail
    job = Delayed::Job.where("handler like '%PersonNotifier::NotifyJob%'").last
    assert job.run_at >= time + @member.notification_time.hours
    assert job.run_at < time + (@member.notification_time+1).hours
  end

  should 'do not schedule duplicated notification mail' do
    @member.notification_time = 12
    @member.notifier.schedule_next_notification_mail
    assert_no_difference Delayed::Job, :count do
      @member.notifier.schedule_next_notification_mail
    end
  end

  should 'do not schedule next mail if notification time is zero' do
    @member.notification_time = 0
    assert_no_difference Delayed::Job, :count do
      @member.notifier.schedule_next_notification_mail
    end
  end

  should 'schedule next notifications for all person with notification time greater than zero' do
    @member.notification_time = 1
    @admin.notification_time = 0
    @admin.save!
    @member.save!
    Delayed::Job.delete_all
    PersonNotifier.schedule_all_next_notification_mail
    process_delayed_job_queue
    assert_equal 1, Delayed::Job.count
  end

  should 'do not create duplicated job' do
    PersonNotifier.schedule_all_next_notification_mail
    assert_no_difference Delayed::Job, :count do
      PersonNotifier.schedule_all_next_notification_mail
    end
  end

  should 'schedule after update and set a valid notification time' do
    assert_no_difference Delayed::Job, :count do
      @member.notification_time = 0
      @member.save!
    end
    assert_difference Delayed::Job, :count, 1 do
      @member.notification_time = 12
      @member.save!
    end
  end

  should 'reschedule with changed notification time' do
    time = Time.now
    assert_difference Delayed::Job, :count, 1 do
      @member.notification_time = 2
      @member.save!
    end
    assert_no_difference Delayed::Job, :count do
      @member.notification_time = 12
      @member.save!
    end
    @member.notifier.schedule_next_notification_mail
    job = Delayed::Job.where("handler like '%PersonNotifier::NotifyJob%'").last
    assert job.run_at >= time + @member.notification_time.hours
    assert job.run_at < time + (@member.notification_time+1).hours
  end

  should 'display error message if fail to render a notificiation' do
    @community.add_member(@member)
    Comment.create!(:author => @admin, :title => 'test comment', :body => 'body!', :source => @article)
    ActionTracker::Record.any_instance.stubs(:verb).returns("some_invalid_verb")
    process_delayed_job_queue
    notify
    sent = ActionMailer::Base.deliveries.last
    assert_match /cannot render notification for some_invalid_verb/, sent.body
  end

  ActionTrackerConfig.verb_names.each do |verb|
    should "render notification for verb #{verb}" do
      action = mock()
      action.stubs(:verb).returns(verb)
      action.stubs(:user).returns(@member)
      action.stubs(:created_at).returns(DateTime.now)
      action.stubs(:target).returns(fast_create(Forum))
      action.stubs(:comments_count).returns(0)
      action.stubs(:comments).returns([])
      action.stubs(:params).returns({'name' => 'home', 'url' => '/', 'lead' => ''})
      action.stubs(:get_url).returns('')

      notifications = []
      notifications.stubs(:find).returns([action])
      Person.any_instance.stubs(:tracked_notifications).returns(notifications)

      notify
      sent = ActionMailer::Base.deliveries.last
      assert_no_match /cannot render notification for #{verb}/, sent.body
    end
  end

  should 'exists? method in NotifyAllJob return false if there is no instance of this class created' do
    Delayed::Job.enqueue(PersonNotifier::NotifyJob.new)
    assert !PersonNotifier::NotifyAllJob.exists?
  end

  should 'exists? method in NotifyAllJob return false if there is no jobs created' do
    assert !PersonNotifier::NotifyAllJob.exists?
  end

  should 'exists? method in NotifyAllJob return true if there is at least one instance of this class' do
    Delayed::Job.enqueue(PersonNotifier::NotifyAllJob.new)
    assert PersonNotifier::NotifyAllJob.exists?
  end

  should 'perform create NotifyJob for all users with notification_time' do
    assert_difference Delayed::Job, :count, 2 do
      Delayed::Job.enqueue(PersonNotifier::NotifyAllJob.new)
      process_delayed_job_queue
    end
  end

  should 'perform create NotifyJob for all users with notification_time defined greater than zero' do
    @member.notification_time = 1
    @admin.notification_time = 0
    @admin.save!
    @member.save!
    Delayed::Job.delete_all
    Delayed::Job.enqueue(PersonNotifier::NotifyAllJob.new)
    process_delayed_job_queue
    assert_equal 1, Delayed::Job.count
  end

  should 'NotifyJob failed jobs create a new NotifyJob on permanent failure' do
    Delayed::Job.enqueue(PersonNotifier::NotifyJob.new(@member.id))

    PersonNotifier.any_instance.stubs(:notify).raises('error')

    process_delayed_job_queue
    jobs = Delayed::Job.all

    assert 1, jobs.select{|j| j.failed?}.size
    assert 1, jobs.select{|j| !j.failed?}.size
  end

  def notify
    @member.notifier.notify
  end

end
