# Task is the base class of ... tasks! Its instances represents tasks that must
# be confirmed by someone (like an environment administrator) or by noosfero
# itself.
#
# The specific types of tasks <em>must</em> override the #perform method, so
# the actual action associated to the type of task can be performed. See the
# documentation of the #perform method for details. 
#
# This class has a +status+ field of type <tt>text</tt>, where you can store
# any type of data (as serialized Ruby objects) you need for your subclass .
class Task < ActiveRecord::Base

  module Status
    # the status of tasks just created
    ACTIVE = 1

    # the status of a task that was cancelled.
    CANCELLED = 2

    # the status os a task that was successfully finished
    FINISHED = 3
  end

  belongs_to :requestor, :class_name => 'Person', :foreign_key => :requestor_id
  belongs_to :target, :class_name => 'Profile', :foreign_key => :target_id

  def initialize(*args)
    super
    self.status ||= Task::Status::ACTIVE
  end

  # this method finished the task. It calls #perform, which must be overriden
  # by subclasses. At the end a message (as returned by #finish_message) is
  # sent to the requestor with #notify_requestor.
  def finish
    transaction do
      self.status = Task::Status::FINISHED
      self.end_date = Time.now
      self.save!
      self.perform
      self.notify_requestor(self.finish_message)
    end
  end

  # this method cancels the task. At the end a message (as returned by
  # #cancel_message) is sent to the requestor with #notify_requestor.
  def cancel
    transaction do
      self.status = Task::Status::CANCELLED
      self.end_date = Time.now
      self.save!
      self.notify_requestor(self.cancel_message)
    end
  end

  protected

  # This method must be overrided in subclasses, and its implementation must do
  # the job the task is intended to. This method will be called when the finish
  # method is called.
  #
  # To cancel the finish of the task, you can throw an exception in perform.
  #
  # The implementation on Task class just does nothing.
  def perform
  end

  # sends a message to the requestor
  def notify_requestor(msg)
    # TODO: implement message sending
  end

  # The message that will be sent to the requestor of the task when its
  # finished.
  def finish_message
    _("The task was finished at %s") % (self.end_date.to_s)
  end

  # The message that will be sent to the requestor of the task when its
  # cancelled.
  def cancel_message
    _("The task was cancelled at %s") % (self.end_date.to_s)
  end

end
