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

    recipients task.target.contact_email

    from task.requestor.environment.contact_email
    subject task.description
    body :requestor => task.requestor.name,
      :target => task.target.name,
      :message => msg,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
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

    recipients task.requestor.email
    from task.requestor.environment.contact_email
    subject task.description
    body :requestor => task.requestor.name,
      :message => text,
      :environment => task.requestor.environment.name,
      :url => url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')
  end

end
