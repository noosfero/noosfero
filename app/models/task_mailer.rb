class TaskMailer < ActionMailer::Base

  def task_finished(task)
    send_message(task, task.finish_message)
  end

  def task_created(task)
    send_message(task, task.create_message)
  end

  def task_cancelled(task)
    send_message(task, task.cancel_message)
  end

  protected

  def send_message(task, message)

    text =
      if message.kind_of?(Proc)
        self.instance_eval(&message)
      else
        message
      end

    recipients task.requestor.email
    from task.requestor.environment.contact_email
    subject task.description
    body :requestor => task.requestor.name,
      :message => text,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
  end

end
