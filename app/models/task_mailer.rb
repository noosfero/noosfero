class TaskMailer < ActionMailer::Base

  def method_missing(name, *args)
    task = args.shift
    if task.kind_of?(Task) && task.respond_to?("#{name}_message")
      send_message(task, task.send("#{name}_message"), *args)
    else
      super
    end
  end

  def target_notification(task, message)
    msg = extract_message(message)

    recipients task.target.notification_emails

    url_for_tasks_list = task.target.kind_of?(Environment) ? '' : url_for(task.target.url.merge(:controller => 'tasks', :action => 'index'))

    from self.class.generate_from(task)
    subject '[%s] %s' % [task.requestor.environment.name, task.description]
    body :requestor => task.requestor.name,
      :target => task.target.name,
      :message => msg,
      :environment => task.requestor.environment.name,
      :url => generate_environment_url(task, :controller => 'home'),
      :tasks_url => url_for_tasks_list
  end

  def invitation_notification(task)
    msg = task.message
    msg = msg.gsub(/<user>/, task.requestor.name)
    msg = msg.gsub(/<friend>/, task.friend_name.blank? ? task.friend_email : task.friend_name)
    msg = msg.gsub(/<url>/, generate_environment_url(task, :controller => 'account', :action => 'signup', :invitation_code => task.code))

    recipients task.friend_email

    from self.class.generate_from(task)
    subject '[%s] %s' % [ task.requestor.environment.name, task.description ]
    body :message => msg
  end

  protected

  def extract_message(message)
    if message.kind_of?(Proc)
      self.instance_eval(&message)
    else
      message.to_s
    end
  end

  def send_message(task, message)

    text = extract_message(message)

    recipients task.requestor.notification_emails
    from self.class.generate_from(task)
    subject '[%s] %s' % [task.requestor.environment.name, task.description]
    body :requestor => task.requestor.name,
      :message => text,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
  end

  def self.generate_from(task)
    "#{task.requestor.environment.name} <#{task.requestor.environment.contact_email}>"
  end

  def generate_environment_url(task, url = {})
    url_for(Noosfero.url_options.merge(:host => task.requestor.environment.default_hostname).merge(url))
  end

end
