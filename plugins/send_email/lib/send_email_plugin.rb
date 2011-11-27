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

  def parse_content(raw_content)
    if context.profile
      raw_content.gsub(/\{sendemail\}/, "/profile/#{context.profile.identifier}/plugins/send_email/deliver")
    else
      raw_content.gsub(/\{sendemail\}/, '/plugin/send_email/deliver')
    end
  end

end
