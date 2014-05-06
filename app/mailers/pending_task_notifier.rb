class PendingTaskNotifier < ActionMailer::Base

  def notification(person)
    @person = person
    @tasks = person.tasks.pending
    @organizations_with_pending_tasks = person.organizations_with_pending_tasks
    @environment = person.environment.name
    @url = url_for(:host => person.environment.default_hostname, :controller => 'home')
    @default_hostname = person.environment.default_hostname
    @url_for_pending_tasks = url_for(:host => person.environment.default_hostname, :controller => 'tasks', :profile => person.identifier)

    mail(
      to: person.email,
      from: "#{person.environment.name} <#{person.environment.noreply_email}>",
      subject: _("[%s] Pending tasks") % person.environment.name
    )
  end

end
