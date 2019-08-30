class UserMailer < ApplicationMailer
  include EmailTemplateHelper

  def activation_email_notify(user)
    self.environment = user.environment

    user_email = "#{user.login}@#{user.email_domain}"
    @name = user.name
    @email = user_email
    @webmail = MailConf.webmail_url(user.login, user.email_domain)
    @url = url_for(host: user.environment.default_hostname, controller: "home")

    mail(
      to: user_email,
      from: "#{user.environment.name} <#{user.environment.noreply_email}>".html_safe,
      subject: _("[%{environment}] Welcome to %{environment} mail!").html_safe % { environment: user.environment.name }
    )
  end

  def activation_code(user)
    self.environment = user.environment

    @recipient = user.name
    @short_activation_code = user.short_activation_code.try(:upcase)
    @url = user.environment.top_url
    @activation_url = url_for(controller: :account, action: :activate,
                              activation_token: user.activation_code,
                              redirection: (true if user.return_to),
                              join: user.community_to_join)

    mail_with_template(
      from: "#{user.environment.name} <#{user.environment.noreply_email}>",
      to: user.email,
      subject: _("[%s] Activate your account").html_safe % [user.environment.name],
      email_template: user.environment.email_templates.find_by_template_type(:user_activation),
    )
  end

  def signup_welcome_email(user)
    self.environment = user.environment

    @body = user.environment.signup_welcome_text_body.gsub("{user_name}", user.name)
    email_subject = user.environment.signup_welcome_text_subject
    mail(
      content_type: "text/html",
      to: user.email,
      from: "#{user.environment.name} <#{user.environment.noreply_email}>".html_safe,
      subject: email_subject.blank? ? _("Welcome to environment %s").html_safe % [user.environment.name] : email_subject,
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
      content_type: "text/html",
      to: user.email,
      from: "#{user.environment.name} <#{user.environment.noreply_email}>".html_safe,
      subject: _("[%s] What about grow up your network?").html_safe % user.environment.name
    )
  end

  class Job < Struct.new(:user, :method)
    def perform
      UserMailer.send(method, user).deliver
    end
  end
end
