class Contact

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
  attr_accessor :state
  attr_accessor :city
  attr_accessor :receive_a_copy
  attr_accessor :dest
  attr_accessor :sender

  N_('Subject'); N_('Message'); N_('City and state'); N_('e-Mail'); N_('Name')

  validates_presence_of :subject, :email, :message, :name
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda {|o| !o.email.blank?})

  def deliver
    return false unless self.valid?
    Contact::Sender.deliver_mail(self)
  end

  class Sender < ActionMailer::Base
    def mail(contact)
      content_type 'text/html'
      emails = contact.dest.notification_emails
      recipients emails
      from "#{contact.name} <#{contact.dest.environment.contact_email}>"
      reply_to contact.email
      if contact.sender
        headers 'X-Noosfero-Sender' => contact.sender.identifier
      end
      if contact.receive_a_copy
        cc "#{contact.name} <#{contact.email}>"
      end
      subject "[#{contact.dest.short_name(30)}] " + contact.subject
      body :name => contact.name,
        :email => contact.email,
        :city => contact.city,
        :state => contact.state,
        :message => contact.message,
        :environment => contact.dest.environment.name,
        :url => url_for(:host => contact.dest.environment.default_hostname, :controller => 'home'),
        :target => contact.dest.name
    end
  end

end
