class Mailing < ActiveRecord::Base

  validates_presence_of :source_id, :subject, :body
  belongs_to :source, :foreign_key => :source_id, :polymorphic => true
  belongs_to :person

  has_many :mailing_sents

  xss_terminate :only => [ :subject, :body ], :with => 'white_list', :on => 'validation'

  after_create do |mailing|
    Delayed::Job.enqueue MailingJob.new(mailing.id)
  end

  def generate_from
    "#{source.name} <#{source.contact_email}>"
  end

  def generate_subject
    '[%s] %s' % [source.name, subject]
  end

  def signature_message
    _('Sent by Noosfero.')
  end

  def url
    ''
  end

  def already_sent_mailing_to?(recipient)
    self.mailing_sents.find_by_person_id(recipient.id)
  end

  def deliver
    offset = 0
    people = []
    each_recipient do |recipient|
      Mailing::Sender.deliver_mail(self, recipient.email)
      self.mailing_sents.create(:person => recipient)
    end
  end

  class Sender < ActionMailer::Base
    def mail(mailing, recipient)
      content_type 'text/html'
      recipients recipient
      from mailing.generate_from
      reply_to mailing.person.email
      subject mailing.generate_subject
      body :message => mailing.body,
        :signature_message => mailing.signature_message,
        :url => mailing.url
    end
  end
end
