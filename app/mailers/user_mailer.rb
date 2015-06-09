class UserMailer < ApplicationMailer

  include EmailTemplateHelper

  def activation_email_notify(user)
    self.environment = user.environment

    user_email = "#{user.login}@#{user.email_domain}"
    @name = user.name
    @email = user_email
    @webmail = MailConf.webmail_url(user.login, user.email_domain)
    @url = url_for(:host => user.environment.default_hostname, :controller => 'home')

    mail(
      to: user_email,
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      subject: _("[%{environment}] Welcome to %{environment} mail!") % { :environment => user.environment.name }
    )
  end

  def activation_code(user)
    self.environment = user.environment

    @recipient = user.name
    @activation_code = user.activation_code
    @url = user.environment.top_url
    @redirection = (true if user.return_to)
    @join = (user.community_to_join if user.community_to_join)

    mail_with_template(
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      to: user.email,
      subject: _("[%s] Activate your account") % [user.environment.name],
      template_params: {:environment => user.environment, :activation_code => @activation_code, :redirection => @redirection, :join => @join, :person => user.person, :url => @url},
      email_template: user.environment.email_templates.find_by_template_type(:user_activation),
    )
  end

  def signup_welcome_email(user)
    self.environment = user.environment

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

  def profiles_suggestions_email(user)
    self.environment = user.environment

    @recipient = user.name
    @url = user.environment.top_url
    @people_suggestions_url = user.people_suggestions_url
    @people_suggestions = user.suggested_people.sample(3)
    @communities_suggestions_url = user.communities_suggestions_url
    @communities_suggestions = user.suggested_communities.sample(3)

    mail(
      content_type: 'text/html',
      to: user.email,
      from: "#{user.environment.name} <#{user.environment.contact_email}>",
      subject: _("[%s] What about grow up your network?") % user.environment.name
    )
  end

  class Job < Struct.new(:user, :method)
    def perform
      UserMailer.send(method, user).deliver
    end
  end
end
