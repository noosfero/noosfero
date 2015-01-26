require_relative "../test_helper"

class TaskTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_relationship_with_requestor
    t = Task.create
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.requestor = 1
    end
    assert_nothing_raised do
      t.requestor = Profile.new
    end
  end

  should 'target be able to polymorphic relationship' do
    t = Task.create
    assert_nothing_raised do
      t.target = Environment.new
    end
    assert_nothing_raised do
      t.target = Profile.new
    end
  end

  def test_should_call_perform_in_finish
    TaskMailer.expects(:generic_message).with('task_finished', anything)
    t = Task.create
    t.requestor = sample_user
    t.expects(:perform)
    t.finish
    assert_equal Task::Status::FINISHED, t.status
  end

  def test_should_have_cancelled_status_after_cancel
    TaskMailer.expects(:generic_message).with('task_cancelled', anything)
    t = Task.create
    t.requestor = sample_user
    t.cancel
    assert_equal Task::Status::CANCELLED, t.status
  end

  def test_should_start_with_active_status
    t = Task.create
    assert_equal Task::Status::ACTIVE, t.status
  end

  def test_should_notify_finish
    t = Task.create
    t.requestor = sample_user

    TaskMailer.expects(:generic_message).with('task_finished', t)

    t.finish
  end

  def test_should_notify_cancel
    t = Task.create
    t.requestor = sample_user

    TaskMailer.expects(:generic_message).with('task_cancelled', t)

    t.cancel
  end

  def test_should_not_notify_when_perform_fails
    count = Task.count

    t = Task.create
    class << t
      def perform
        raise RuntimeError
      end
    end

    t.expects(:notify_requestor).never
    assert_raise RuntimeError do
      t.finish
    end
  end

  should 'provide a description method' do
    requestor = create_user('requestor').person
    assert_kind_of Hash, build(Task, :requestor => requestor).information
  end

  should 'notify just after the task is created' do
    task = Task.new
    task.requestor = sample_user

    TaskMailer.expects(:generic_message).with('task_created', task)
    task.save!
  end

  should 'not notify if the task is hidden' do
    task = build(Task, :status => Task::Status::HIDDEN)
    task.requestor = sample_user

    TaskMailer.expects(:generic_message).with('task_created', anything).never
    task.save!
  end

  should 'generate a random code before validation' do
    Task.expects(:generate_code)
    Task.new.valid?
  end

  should 'make sure that codes are unique' do
    task1 = Task.create!
    task2 = build(Task, :code => task1.code)

    assert !task2.valid?
    assert task2.errors[:code.to_s].present?
  end

  should 'generate a code with chars from a-z and 0-9' do
    code = Task.generate_code
    assert(code =~ /^[a-z0-9]+$/)
    assert_equal 36, code.size
  end

  should 'find only in active tasks' do
    task = Task.new
    task.requestor = sample_user
    task.save!

    task.cancel

    assert_nil Task.find_by_code(task.code)
  end

  should 'be able to find active tasks' do
    task = Task.new
    task.requestor = sample_user
    task.save!

    assert_not_nil Task.find_by_code(task.code)
  end

  should 'use 36-chars codes by default' do
    assert_equal 36, Task.create.code.size
  end

  should 'be able to limit the length of the generated code' do
    assert_equal 3, Task.create!(:code_length => 3).code.size
    assert_equal 7, Task.create!(:code_length => 7).code.size
  end

  should 'throws exception when try to send target_notification_message in Task base class' do
    task = Task.new
    assert_raise NotImplementedError do
      task.target_notification_message
    end
  end

  should 'send notification to target just after task creation' do
    task = Task.new
    target = fast_create(Profile)
    target.stubs(:notification_emails).returns(['adm@example.com'])
    task.target = target
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')

    mailer = mock
    mailer.expects(:deliver).once
    TaskMailer.expects(:target_notification).returns(mailer).once
    task.save!
  end

  should 'not send notification to target if the task is hidden' do
    task = build(Task, :status => Task::Status::HIDDEN)
    target = fast_create(Profile)
    target.stubs(:notification_emails).returns(['adm@example.com'])
    task.target = target
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')

    TaskMailer.expects(:target_notification).never
    task.save!
  end

  should 'be able to list pending tasks' do
    Task.delete_all
    t1 = Task.create!
    t2 = Task.create!
    t2.finish
    t3 = Task.create!

    assert_equivalent [t1,t3], Task.pending
  end

  should 'be able to list finished tasks' do
    Task.delete_all
    t1 = Task.create!
    t2 = Task.create!
    t2.finish
    t3 = Task.create!

    assert_equal [t2], Task.finished
  end

  should 'has perform task permission' do
    t = Task.new
    assert_equal :perform_task, t.permission
  end

  should 'be destroyed when requestor destroyed' do
    user = create_user('test_user').person
    assert_no_difference 'Task.count' do
      create(Task, :requestor => user)
      user.destroy
    end
  end

  should 'not deliver notification message to target' do
    task = Task.new
    assert_raise NotImplementedError do
      task.target_notification_message
    end
  end

  should 'not send message when created, finished or cancelled' do
    task = Task.new
    %w[ created finished cancelled ].each do |action|
      assert_raise NotImplementedError do
        task.send("task_#{action}_message")
      end
    end
  end

  should 'not notify target if message is nil' do
    task = Task.new
    task.stubs(:target_notification_message).returns(nil)
    TaskMailer.expects(:target_notification).never
    task.save!
  end

  should 'not notify target if notification emails is empty' do
    task = Task.new
    target = Profile.new
    target.stubs(:notification_emails).returns([])
    task.target = target
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')
    TaskMailer.expects(:target_notification).never
    task.save!
  end

  should 'the environment method be defined' do
    task = Task.new
    assert task.method_exists?('environment')
  end

  should 'the task environment method return the target environment' do
    task = Task.new
    target = build(Profile, :environment => Environment.new)
    task.target = target
    assert_equal task.environment, target.environment
  end

  should 'the task environment method return nil if the target task is nil' do
    task = Task.new
    assert_equal task.environment, nil
  end

  should 'have blank string on target_notification_description in Task base class' do
    task = Task.new
    assert_equal '', task.target_notification_description
  end

  should 'activate task' do
    task = build(Task, :status => Task::Status::HIDDEN)
    task.activate
    assert_equal Task::Status::ACTIVE, task.status
  end

  should 'notify just after the task is activated' do
    task = build(Task, :status => Task::Status::HIDDEN)
    task.requestor = sample_user
    task.save!

    TaskMailer.expects(:generic_message).with('task_activated', task)
    task.activate
  end

  should 'send notification message to target just after task activation' do
    task = build(Task, :status => Task::Status::HIDDEN)
    target = fast_create(Profile)
    target.stubs(:notification_emails).returns(['target@example.com'])
    task.target = target
    task.save!
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')

    mailer = mock
    mailer.expects(:deliver).once
    TaskMailer.expects(:target_notification).returns(mailer).once
    task.activate
  end

  should 'filter tasks to a profile' do
    requestor = fast_create(Person)
    person = fast_create(Person)
    another_person = fast_create(Person)
    environment = Environment.default
    environment.add_admin(person)
    t1 = create(Task, :requestor => requestor, :target => person)
    t2 = create(Task, :requestor => requestor, :target => person)
    t3 = create(Task, :requestor => requestor, :target => environment)
    t4 = create(Task, :requestor => requestor, :target => another_person)

    assert_includes Task.to(person), t1
    assert_includes Task.to(person), t2
    assert_includes Task.to(person), t3
    assert_not_includes Task.to(person), t4
    assert_includes Task.to(another_person), t4
  end

  should 'filter tasks by type with named_scope' do
    class CleanHouse < Task; end
    class FeedDog < Task; end
    requestor = fast_create(Person)
    target = fast_create(Person)
    t1 = create(CleanHouse, :requestor => requestor, :target => target)
    t2 = create(CleanHouse, :requestor => requestor, :target => target)
    t3 = create(FeedDog, :requestor => requestor, :target => target)
    type = t1.type

    assert_includes Task.of(type), t1
    assert_includes Task.of(type), t2
    assert_not_includes Task.of(type), t3
    assert_includes Task.of(nil), t3
  end

  should 'order tasks by some attribute correctly' do
    Task.destroy_all
    t1 = fast_create(Task, :status => 4, :created_at => Time.now + 1.hour)
    t2 = fast_create(Task, :status => 3, :created_at => Time.now + 2.hour)
    t3 = fast_create(Task, :status => 2, :created_at => Time.now + 3.hour)
    t4 = fast_create(Task, :status => 1, :created_at => Time.now + 4.hour)

    assert_equal [t1,t2,t3,t4], Task.order_by('created_at', 'asc')
    assert_equal [t4,t3,t2,t1], Task.order_by('created_at', 'desc')
    assert_equal [t1,t2,t3,t4], Task.order_by('status', 'desc')
    assert_equal [t4,t3,t2,t1], Task.order_by('status', 'asc')
  end

  should 'retrieve tasks by status' do
    pending = fast_create(Task, :status => Task::Status::ACTIVE)
    hidden = fast_create(Task, :status => Task::Status::HIDDEN)
    finished = fast_create(Task, :status => Task::Status::FINISHED)
    canceled = fast_create(Task, :status => Task::Status::CANCELLED)

    assert_includes Task.pending, pending
    assert_not_includes Task.pending, hidden
    assert_not_includes Task.pending, finished
    assert_not_includes Task.pending, canceled

    assert_not_includes Task.hidden, pending
    assert_includes Task.hidden, hidden
    assert_not_includes Task.hidden, finished
    assert_not_includes Task.hidden, canceled

    assert_not_includes Task.finished, pending
    assert_not_includes Task.finished, hidden
    assert_includes Task.finished, finished
    assert_not_includes Task.finished, canceled

    assert_not_includes Task.canceled, pending
    assert_not_includes Task.canceled, hidden
    assert_not_includes Task.canceled, finished
    assert_includes Task.canceled, canceled

    assert_includes Task.opened, pending
    assert_includes Task.opened, hidden
    assert_not_includes Task.opened, finished
    assert_not_includes Task.opened, canceled

    assert_not_includes Task.closed, pending
    assert_not_includes Task.closed, hidden
    assert_includes Task.closed, finished
    assert_includes Task.closed, canceled
  end

  should 'be ham by default' do # ham means not spam
    assert_equal false, Task.create.spam
  end

  should 'be able to mark tasks as spam/ham/unknown' do
    t = Task.new
    t.spam = true
    assert t.spam?
    assert !t.ham?

    t.spam = false
    assert t.ham?
    assert !t.spam?

    t.spam = nil
    assert !t.spam?
    assert !t.ham?
  end

  should 'be able to select non-spam tasks' do
    t1 = fast_create(Task)
    t2 = fast_create(Task, :spam => false)
    t3 = fast_create(Task, :spam => true)

    assert_equivalent [t1,t2], Task.without_spam
  end

  should 'be able to select spam tasks' do
    t1 = fast_create(Task)
    t2 = fast_create(Task, :spam => false)
    t3 = fast_create(Task, :spam => true)

    assert_equivalent [t3], Task.spam
  end

  should 'be able to mark as spam' do
    t1 = fast_create(Task)
    t1.spam!
    t1.reload
    assert t1.spam?
  end

  should 'be able to mark as ham' do
    t1 = fast_create(Task)
    t1.ham!
    t1.reload
    assert t1.ham?
  end

  protected

  def sample_user
    user = build(User, :login => 'testfindinactivetask', :password => 'test', :password_confirmation => 'test', :email => 'testfindinactivetask@localhost.localdomain')
    user.build_person(person_data)
    user.save
    user.person
  end

end
