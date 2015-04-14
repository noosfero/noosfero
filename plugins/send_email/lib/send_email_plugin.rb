require 'send_email_plugin/core_ext'

class SendEmailPlugin < Noosfero::Plugin

  def self.plugin_name
    "SendEmailPlugin"
  end

  def self.plugin_description
    _("A plugin that allows sending e-mails via HTML forms.")
  end

  def stylesheet?
    true
  end

  def parse_content(html, source)
    if context.profile
      html.gsub!(/({|%7[Bb])sendemail(}|%7[Dd])/, "/profile/#{context.profile.identifier}/plugin/send_email/deliver")
    else
      html.gsub!(/({|%7[Bb])sendemail(}|%7[Dd])/, '/plugin/send_email/deliver')
    end
    [html, source]
  end

end

require_dependency 'send_email_plugin/mail'
require_dependency 'send_email_plugin/sender'
