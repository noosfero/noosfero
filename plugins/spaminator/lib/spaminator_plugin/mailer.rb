class SpaminatorPlugin::Mailer < Noosfero::Plugin::MailerBase

  def inactive_person_notification(person)
    hostname = person.hostname || person.environment.default_hostname
    recipients    person.email
    from          'no-reply@' + hostname
    subject       _("[%s] You must reactivate your account.") % person.environment.name
    content_type  'text/html'
    body :person => person,
         :environment => person.environment,
         :url => url_for(:host => hostname, :controller => 'account', :action => 'forgot_password')
  end

end
