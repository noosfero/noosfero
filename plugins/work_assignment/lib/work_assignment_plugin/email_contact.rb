class WorkAssignmentPlugin::EmailContact

  include ActiveModel::Validations

  def initialize(attributes = nil)
    if attributes
      attributes.each do |attr,value|
        self.send("#{attr}=", value)
      end
    end
  end

  attr_accessor :name
  attr_accessor :subject
  attr_accessor :message
  attr_accessor :email
  attr_accessor :receive_a_copy
  attr_accessor :sender
  attr_accessor :receiver

  N_('Subject'); N_('Message'); N_('e-Mail'); N_('Name')

  validates_presence_of :receiver, :subject, :message, :sender
  validates_format_of :receiver, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda {|o| !o.email.blank?})

  def deliver
    return false unless self.valid?
    WorkAssignmentPlugin::EmailContact::EmailSender.notification(self).deliver
  end

  class EmailSender < ActionMailer::Base

    def notification(email_contact)
      name = email_contact.sender.name
      email = email_contact.sender.email
      message = email_contact.message
      target = email_contact.receiver

      options = {
        content_type: 'text/html',
        to: target,
        reply_to: email,
        subject: email_contact.subject,
        body: message,
        from: "#{email_contact.sender.environment.name} <#{email_contact.sender.environment.contact_email}>",
      }

      mail(options)
    end

    def build_mail_message(email_contact, uploaded_files)
      message = ""
      if uploaded_files && uploaded_files.first && uploaded_files.first.parent && uploaded_files.first.parent.parent
        article = uploaded_files.first.parent.parent
        message = article.default_email + "<br>"
        uploaded_files.each do |file|
          url = url_for(file.url)
          message += "<br><a href='#{url}'>#{url}</a>"
        end
      end
      email_contact.message = message
    end
  end
end
