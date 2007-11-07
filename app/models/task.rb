# Task is the base class of ... tasks! Its instances represents tasks that must
# be confirmed by someone (like an environment administrator) or by noosfero
# itself.
#
# The specific types of tasks <em>must</em> override the #perform method, so
# the actual action associated to the type of task can be performed. See the
# documentation of the #perform method for details. 
#
# This class has a +data+ field of type <tt>text</tt>, where you can store any
# type of data (as serialized Ruby objects) you need for your subclass (which
# will need to declare <ttserialize</tt> itself).
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

  validates_uniqueness_of :code, :on => :create
  validates_presence_of :code

  attr_protected :status

  def initialize(*args)
    super
    self.status ||= Task::Status::ACTIVE
  end

  before_validation_on_create do |task|
    if task.code.nil?
      task.code = Task.generate_code
      while (Task.find_by_code(task.code))
        task.code = Task.generate_code
      end
    end
  end

  after_create do |task|
    task.send(:send_notification, :created)
    
    target_msg = task.target_notification_message
    unless target_msg.nil?
      TaskMailer.deliver_target_notification(task, target_msg)
    end
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
      send_notification(:finished)
    end
  end

  # this method cancels the task. At the end a message (as returned by
  # #cancel_message) is sent to the requestor with #notify_requestor.
  def cancel
    transaction do
      self.status = Task::Status::CANCELLED
      self.end_date = Time.now
      self.save!
      send_notification(:cancelled)
    end
  end


  # Returns the description of the task.
  #
  # This method +must+ be overriden in subclasses to return something
  # meaningful for each kind of task  
  def description
    _('Generic task')
  end

  # The message that will be sent to the requestor of the task when the task is
  # created.
  def task_created_message
    # FIXME: use a date properly recorded.
    _("The task was created at %s") % Time.now
  end

  # The message that will be sent to the requestor of the task when its
  # finished.
  def task_finished_message
    _("The task was finished at %s") % (self.end_date.to_s)
  end

  # The message that will be sent to the requestor of the task when its
  # cancelled.
  def task_cancelled_message
    _("The task was cancelled at %s") % (self.end_date.to_s)
  end

  # The message that will be sent to the *target* of the task when it is
  # created. The indent of this message is to notify the target about the
  # request that was just created for him/her. 
  #
  # The implementation in this class returns +nil+, what makes the notification
  # not to be sent. If you want to send a notification to the target upon task
  # creation, override this method and return a String.
  def target_notification_message
    nil
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

  # sends notification e-mail about a task, if the task has a requestor.
  def send_notification(action)
    TaskMailer.send("deliver_task_#{action}", self) if self.requestor
  end

  class << self

    def pending_for(target, conditions= nil)
      self.find(:all, :conditions => { :target_id => target.id, :status =>  Task::Status::ACTIVE }.merge(conditions || {}))
    end

    # generates a random code string consisting of 36 characters in the ranges
    # a-z and 0-9
    def generate_code
      chars = ('a'..'z').to_a + ('0'..'9').to_a
      code = ""
      chars.size.times do |n|
        code << chars[rand(chars.size)]
      end
      code
    end

    # finds a task by its (generated) code. Only returns a task with the
    # specified code AND with status = Task::Status::ACTIVE.
    #
    # Can be used in subclasses to find only their instances.
    def find_by_code(code)
      self.find(:first, :conditions => { :code => code, :status => Task::Status::ACTIVE })
    end

  end

end
