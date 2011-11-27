class SendEmailPlugin::Sender < Noosfero::Plugin::MailerBase
  prepend_view_path(SendEmailPlugin.root_path+'/views')

  def mail(referer, url, mail)
    recipients mail.to
    from mail.from
    subject "[#{mail.environment.name}] #{mail.subject}"
    body :message => mail.message,
      :referer => referer,
      :context_url => url,
      :params => mail.params
  end
end
