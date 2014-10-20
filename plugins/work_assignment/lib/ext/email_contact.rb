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
  attr_accessor :receiver
  attr_accessor :sender

  N_('Subject'); N_('Message'); N_('e-Mail'); N_('Name')

  validates_presence_of :subject, :email, :message, :name
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda {|o| !o.email.blank?})

  def deliver
    return false unless self.valid?
    EmailContact::EmailSender.notification(self).deliver
  end

  class EmailSender < ActionMailer::Base

    def notification(email_contact)
      @name = email_contact.name
      @email = email_contact.email
      @message = email_contact.message
      @target = email_contact.receiver

      options = {
        content_type: 'text/html',
        to: email_contact.receiver,
        reply_to: email_contact.email,
        subject: email_contact.subject,
        body: email_contact.message,
        from: "#{email_contact.name} <#{email_contact.email}>"
      }

      if email_contact.receive_a_copy == "1"
        options.merge!(cc: "#{email_contact.email}")
      end

      mail(options)
    end
  end

  def build_mail_message(environment, uploaded_files, parent_id)
    @article = environment.articles.find_by_id(parent_id)
    @message = ""
    if !@article.nil? && @article.type == "WorkAssignmentPlugin::WorkAssignment"
      @message = @article.default_email + "<br>"
    end
    uploaded_files.each do |file|
      @real_file_url = "http://#{file.url[:host]}:#{file.url[:port]}/#{file.url[:profile]}/#{file.path}"
      @message += "<br><a href='#{@real_file_url}'>#{@real_file_url}</a>"
    end
    @message
  end

end
