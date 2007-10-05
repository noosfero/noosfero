require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    TaskMailer.stubs(:deliver_task_created)
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

  def test_relationship_with_target
    t = Task.create
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.target = 1
    end
    assert_nothing_raised do
      t.target = Profile.new
    end
  end

  def test_should_call_perform_in_finish
    TaskMailer.expects(:deliver_task_finished)
    t = Task.create
    t.expects(:perform)
    t.finish
    assert_equal Task::Status::FINISHED, t.status
  end

  def test_should_have_cancelled_status_after_cancel
    TaskMailer.expects(:deliver_task_cancelled)
    t = Task.create
    t.cancel
    assert_equal Task::Status::CANCELLED, t.status
  end

  def test_should_start_with_active_status
    t = Task.create
    assert_equal Task::Status::ACTIVE, t.status
  end

  def test_should_notify_finish
    t = Task.create
    TaskMailer.expects(:deliver_task_finished).with(t)
    t.finish
  end

  def test_should_notify_cancel
    t = Task.create
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
    assert_kind_of String, Task.new.description
  end

  should 'notify just after the task is created' do
    task = Task.new
    TaskMailer.expects(:deliver_task_created).with(task)
    task.save!
  end


end
