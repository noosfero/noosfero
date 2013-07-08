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

  def parse_content(args)
    raw_content = args[:html]
    if context.profile
      raw_content.gsub(/\{sendemail\}/, "/profile/#{context.profile.identifier}/plugin/send_email/deliver")
    else
      raw_content.gsub(/\{sendemail\}/, '/plugin/send_email/deliver')
    end
    args.clone.merge({:html => raw_content})
  end

end
