class SendEmailPlugin::Mail < ActiveRecord::Base #WithoutTable

  N_('Subject'); N_('Message'); N_('To'); N_('From')
  tableless :columns => [
    [:from, :string],
    [:to, :string],
    [:subject, :string, _('New mail')],
    [:message, :string],
    [:params, :hash, {}],
  ]
  attr_accessor :environment

  validates_presence_of :environment
  validates_presence_of :to, :message

  def validate
    if to_as_list.any? do |value|
        if value !~ Noosfero::Constants::EMAIL_FORMAT
          self.errors.add(:to, _("%{fn} '%s' isn't a valid e-mail address") % value)
        end
      end
    else
      allowed_emails = environment ? environment.send_email_plugin_allow_to.to_s.gsub(/\s+/, '').split(/,/) : []
      if to_as_list.any? do |value|
          if !allowed_emails.include?(value)
            self.errors.add(:to, _("%{fn} '%s' address is not allowed (see SendEmailPlugin config)") % value)
          end
        end
      end
    end
  end

  def params=(value = {})
    [:action, :controller, :to, :message, :subject, :from].each{|k| value.delete(k)}
    self[:params] = value
  end

  def to_as_list
    to && to.split(/,/) || []
  end

end
