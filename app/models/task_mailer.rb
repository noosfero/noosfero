class TaskMailer < ActionMailer::Base

  def task_finished(task)
    recipients task.requestor.email
    from task.requestor.environment.contact_email
    subject task.description
    body :requestor => task.requestor.name,
      :message => task.finish_message,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
  end

  def task_cancelled(task)
    recipients task.requestor.email
    from task.requestor.environment.contact_email
    subject task.description
    body :requestor => task.requestor.name,
      :message => task.cancel_message,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
  end

end
