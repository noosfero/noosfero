class SendEmailPlugin::Sender < Noosfero::Plugin::MailerBase

  def message(referer, url, mail)
    @message = mail.message
    @referer = referer
    @context_url = url
    @params = mail.params

    mail(
      recipients: mail.to,
      from: mail.from,
      subject: "[#{mail.environment.name}] #{mail.subject}"
    )
  end
end
