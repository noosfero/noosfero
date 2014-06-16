class UserMailer < ActionMailer::Base
  def activation_email_notify(user)
    user_email = "#{user.login}@#{user.email_domain}"
    @name = user.name
    @email = user_email
    @webmail = MailConf.webmail_url(user.login, user.email_domain)
    @environment = user.environment.name
    @url = url_for(:host => user.environment.default_hostname, :controller => 'home')

    mail(
      to: user_email,
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      subject: _("[%{environment}] Welcome to %{environment} mail!") % { :environment => user.environment.name }
    )
  end

  def activation_code(user)
    @recipient = user.name,
    @activation_code = user.activation_code
    @environment = user.environment.name
    @url = user.environment.top_url

    mail(
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      to: user.email,
      subject: _("[%s] Activate your account") % [user.environment.name],
    )
  end

  def signup_welcome_email(user)
    @body = user.environment.signup_welcome_text_body.gsub('{user_name}', user.name)
    email_subject = user.environment.signup_welcome_text_subject
    mail(
      content_type: 'text/html',
      to: user.email,
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      subject: email_subject.blank? ? _("Welcome to environment %s") % [user.environment.name] : email_subject,
      body: @body
    )
  end

  class Job < Struct.new(:user, :method)
    def perform
      UserMailer.send(method, user).deliver
    end
  end
end
