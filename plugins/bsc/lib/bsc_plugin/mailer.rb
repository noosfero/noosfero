class BscPlugin::Mailer < Noosfero::Plugin::MailerBase

  prepend_view_path(BscPlugin.root_path+'/views')

  def admin_notification(admin, bsc)
    domain = bsc.hostname || bsc.environment.default_hostname
    recipients    admin.contact_email
    from          'no-reply@' + domain
    subject       _("[%s] Bsc management transferred to you.") % bsc.name
    content_type  'text/html'
    body :bsc => bsc
  end
end
