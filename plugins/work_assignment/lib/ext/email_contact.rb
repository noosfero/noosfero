class EmailContact

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
    EmailContact::EmailSender.notification(self).deliver
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
  end

  def build_mail_message!(environment, uploaded_files, parent_id)
    article = environment.articles.find_by_id(parent_id)
    message = ""
    #kind_of?
    if !article.nil? && article.type == "WorkAssignmentPlugin::WorkAssignment"
      message = article.default_email + "<br>"
    end
    uploaded_files.each do |file|
      file_url = "http://#{file.url[:host]}:#{file.url[:port]}/#{file.url[:profile]}/#{file.path}"
      message += "<br><a href='#{file_url}'>#{file_url}</a>"
    end
    self.message = message
  end

end
