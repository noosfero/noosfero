class SendEmailPlugin::Mail
  include ActiveModel::Validations

  cN_('Subject'); cN_('Message'); N_('To'); cN_('From')

  attr_accessor :environment, :from, :to, :subject, :message, :params

  validates_presence_of :environment
  validates_presence_of :to, :message
  validate :recipients_format

  def initialize(attributes = {:subject => 'New mail'})
    @environment = attributes[:environment]
    @from = attributes[:from]
    @to = attributes[:to]
    @subject = attributes[:subject]
    @message = attributes[:message]
    @params = attributes[:params]
  end

  def recipients_format
    if to_as_list.any? do |value|
        if value !~ Noosfero::Constants::EMAIL_FORMAT
          self.errors.add(:to, _("'%s' isn't a valid e-mail address") % value)
        end
      end
    else
      allowed_emails = environment ? environment.send_email_plugin_allow_to.to_s.gsub(/\s+/, '').split(/,/) : []
      if to_as_list.any? do |value|
          if !allowed_emails.include?(value)
            self.errors.add(:to, _("'%s' address is not allowed (see SendEmailPlugin config)") % value)
          end
        end
      end
    end
  end

  def params=(value = {})
    [:action, :controller, :to, :message, :subject, :from].each{|k| value.delete(k)}
    @params = value
  end

  def to_as_list
    to && to.split(/,/) || []
  end

end
