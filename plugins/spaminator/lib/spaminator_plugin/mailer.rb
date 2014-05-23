class SpaminatorPlugin::Mailer < Noosfero::Plugin::MailerBase

  include Rails.application.routes.url_helpers
  def inactive_person_notification(person)
    mail(
      :to => person.email,
      :from => "#{person.environment.name} <#{person.environment.noreply_email}>",
      :subject => _("[%s] You must reactivate your account.") % person.environment.name,
      :content_type => 'text/html',
      :body => {:person => person,
           :environment => person.environment,
           :url => url_for(:host => person.default_hostname, :controller => 'account', :action => 'forgot_password')}
    )
  end

  class Job < Struct.new(:person, :method)
    def perform
      SpaminatorPlugin::Mailer.send(method, person).deliver
    end
  end

end
