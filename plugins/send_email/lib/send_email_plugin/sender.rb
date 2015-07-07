class SendEmailPlugin::Sender < Noosfero::Plugin::MailerBase

  def send_message(referer, url, mail)
    @message = mail.message
    @referer = referer
    @context_url = url
    @params = mail.params

    mail(
      content_type: 'text/plain',
      to: mail.to,
      from: mail.from,
      subject: "[#{mail.environment.name}] #{mail.subject}"
    )
  end
end
