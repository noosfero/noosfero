class TaskMailer < ApplicationMailer

  include EmailTemplateHelper

  def target_notification(task, message)
    self.environment = task.environment

    @message = extract_message(message)
    @target = task.target.name
    @url = generate_environment_url(task, :controller => 'home')
    url_for_tasks_list = task.target.kind_of?(Environment) ? '' : url_for(task.target.tasks_url.merge(:script_name => Noosfero.root('/')))
    @tasks_url = url_for_tasks_list

    mail(
      to: task.target.notification_emails.compact,
      from: self.class.generate_from(task),
      subject: "[%s] %s" % [task.environment.name, task.target_notification_description]
    )
  end

  def invitation_notification(task)
    self.environment = task.requestor.environment

    msg = task.expanded_message
    @message = msg.gsub /<url>/, generate_environment_url(task, :controller => 'account', :action => 'signup', :invitation_code => task.code)

    mail(
      to: task.friend_email,
      from: self.class.generate_from(task),
      subject: '[%s] %s' % [ task.requestor.environment.name, task.target_notification_description ]
    )
  end

  def generic_message(name, task)
    self.environment = task.requestor.environment

    return if !task.respond_to?("#{name}_message")

    @message = extract_message(task.send("#{name}_message"))
    @requestor = task.requestor.name
    @url = url_for(:host => task.requestor.environment.default_hostname, :controller => 'home')

    mail_with_template(
      to: task.requestor.notification_emails,
      from: self.class.generate_from(task),
      subject: '[%s] %s' % [task.requestor.environment.name, task.target_notification_description],
      email_template: task.email_template,
      template_params: {:environment => task.requestor.environment, :task => task, :message => @message, :url => @url, :requestor => task.requestor}
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
    url_for(Noosfero.url_options.merge(:host => task.environment.default_hostname).merge(url).merge(:script_name => Noosfero.root('/')))
  end

end
