require File.dirname(__FILE__) + '/../test_helper'

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
      t.requestor = Person.new
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
    TaskMailer.expects(:deliver_task_finished)
    t = Task.create
    t.requestor = sample_user
    t.expects(:perform)
    t.finish
    assert_equal Task::Status::FINISHED, t.status
  end

  def test_should_have_cancelled_status_after_cancel
    TaskMailer.expects(:deliver_task_cancelled)
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

    TaskMailer.expects(:deliver_task_finished).with(t)

    t.finish
  end

  def test_should_notify_cancel
    t = Task.create
    t.requestor = sample_user

    TaskMailer.expects(:deliver_task_cancelled).with(t)

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
    assert_kind_of Hash, Task.new(:requestor => requestor).information
  end

  should 'notify just after the task is created' do
    task = Task.new
    task.requestor = sample_user

    TaskMailer.expects(:deliver_task_created).with(task)
    task.save!
  end

  should 'not notify if the task is hidden' do
    task = Task.new(:status => Task::Status::HIDDEN)
    task.requestor = sample_user

    TaskMailer.expects(:deliver_task_created).never
    task.save!
  end

  should 'generate a random code before validation' do
    Task.expects(:generate_code)
    Task.new.valid?
  end

  should 'make sure that codes are unique' do
    task1 = Task.create!
    task2 = Task.new(:code => task1.code)

    assert !task2.valid?
    assert task2.errors.invalid?(:code)
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
    assert_equal 3, Task.create(:code_length => 3).code.size
    assert_equal 7, Task.create(:code_length => 7).code.size
  end

  should 'throws exception when try to send target_notification_message in Task base class' do
    task = Task.new
    assert_raise NotImplementedError do
      task.target_notification_message
    end
  end

  should 'send notification to target just after task creation' do
    task = Task.new
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')
    TaskMailer.expects(:deliver_target_notification).once
    task.save!
  end

  should 'not send notification to target if the task is hidden' do
    task = Task.new(:status => Task::Status::HIDDEN)
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')
    TaskMailer.expects(:deliver_target_notification).never
    task.save!
  end

  should 'be able to list pending tasks' do
    Task.delete_all
    t1 = Task.create!
    t2 = Task.create!
    t2.finish
    t3 = Task.create!

    assert_equal [t1,t3], Task.pending
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
    assert_no_difference Task, :count do
      Task.create(:requestor => user)
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
    TaskMailer.expects(:deliver_target_notification).never
    task.save!
  end

  should 'the environment method be defined' do
    task = Task.new
    assert task.method_exists?('environment')
  end

  should 'the task environment method return the target environment' do
    task = Task.new
    target = Profile.new(:environment => Environment.new)
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
    task = Task.new(:status => Task::Status::HIDDEN)
    task.activate
    assert_equal Task::Status::ACTIVE, task.status
  end

  should 'notify just after the task is activated' do
    task = Task.new(:status => Task::Status::HIDDEN)
    task.requestor = sample_user

    TaskMailer.expects(:deliver_task_activated).with(task)
    task.activate
  end

  should 'send notification message to target just after task activation' do
    task = Task.new(:status => Task::Status::HIDDEN)
    task.save!
    task.stubs(:target_notification_message).returns('some non nil message to be sent to target')
    TaskMailer.expects(:deliver_target_notification).once
    task.activate
  end

  should 'filter tasks to a profile' do
    requestor = fast_create(Person)
    person = fast_create(Person)
    another_person = fast_create(Person)
    environment = Environment.default
    environment.add_admin(person)
    t1 = Task.create(:requestor => requestor, :target => person)
    t2 = Task.create(:requestor => requestor, :target => person)
    t3 = Task.create(:requestor => requestor, :target => environment)
    t4 = Task.create(:requestor => requestor, :target => another_person)

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
    t1 = CleanHouse.create(:requestor => requestor, :target => target)
    t2 = CleanHouse.create(:requestor => requestor, :target => target)
    t3 = FeedDog.create(:requestor => requestor, :target => target)
    type = t1.type

    assert_includes Task.of(type), t1
    assert_includes Task.of(type), t2
    assert_not_includes Task.of(type), t3
    assert_includes Task.of(nil), t3
  end

  should 'order tasks by some attribute correctly' do
    Task.destroy_all
    t1 = fast_create(Task, :status => 4, :created_at => 1)
    t2 = fast_create(Task, :status => 3, :created_at => 2)
    t3 = fast_create(Task, :status => 2, :created_at => 3)
    t4 = fast_create(Task, :status => 1, :created_at => 4)

    assert_equal [t1,t2,t3,t4], Task.order_by('created_at', 'asc')
    assert_equal [t4,t3,t2,t1], Task.order_by('created_at', 'desc')
    assert_equal [t1,t2,t3,t4], Task.order_by('status', 'desc')
    assert_equal [t4,t3,t2,t1], Task.order_by('status', 'asc')
  end

  protected

  def sample_user
    user = User.new(:login => 'testfindinactivetask', :password => 'test', :password_confirmation => 'test', :email => 'testfindinactivetask@localhost.localdomain')
    user.build_person(person_data)
    user.save
    user.person
  end

end
