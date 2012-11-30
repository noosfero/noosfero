class SpaminatorPlugin::Mailer < Noosfero::Plugin::MailerBase

  def inactive_person_notification(person)
    recipients    person.email
    from          "#{person.environment.name} <#{person.environment.contact_email}>"
    subject       _("[%s] You must reactivate your account.") % person.environment.name
    content_type  'text/html'
    body :person => person,
         :environment => person.environment,
         :url => url_for(:host => person.default_hostname, :controller => 'account', :action => 'forgot_password')
  end

end
