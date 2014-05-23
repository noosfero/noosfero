class TaskMailer < ActionMailer::Base

  def target_notification(task, message)
    @message = extract_message(message)
    @target = task.target.name
    @environment = task.environment.name
    @url = generate_environment_url(task, :controller => 'home')
    url_for_tasks_list = task.target.kind_of?(Environment) ? '' : url_for(task.target.tasks_url)
    @tasks_url = url_for_tasks_list

    mail(
      to: task.target.notification_emails.compact,
      from: self.class.generate_from(task),
      subject: "[%s] %s" % [task.environment.name, task.target_notification_description]
    )
  end

  def invitation_notification(task)
    msg = task.expanded_message
    @message = msg.gsub /<url>/, generate_environment_url(task, :controller => 'account', :action => 'signup', :invitation_code => task.code)

    mail(
      to: task.friend_email,
      from: self.class.generate_from(task),
      subject: '[%s] %s' % [ task.requestor.environment.name, task.target_notification_description ]
    )
  end

  def generic_message(name, task)
    return if !task.respond_to?("#{name}_message")

    @message = extract_message(task.send("#{name}_message"))
    @requestor = task.requestor.name
    @environment = task.requestor.environment.name
    @url = url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')

    mail(
      to: task.requestor.notification_emails,
      from: self.class.generate_from(task),
      subject: '[%s] %s' % [task.requestor.environment.name, task.target_notification_description]
    )
  end

  protected

  def extract_message(message)
    if message.kind_of?(Proc)
      self.instance_exec(&message)
    else
      message.to_s
    end
  end

  def self.generate_from(task)
    "#{task.environment.name} <#{task.environment.noreply_email}>"
  end

  def generate_environment_url(task, url = {})
    url_for(Noosfero.url_options.merge(:host => task.environment.default_hostname).merge(url))
  end

end
