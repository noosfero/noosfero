require_dependency "mailing_job"

class Mailing < ApplicationRecord
  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings field: :data

  attr_accessible :subject, :body, :data

  validates_presence_of :source_id, :subject, :body
  belongs_to :source, foreign_key: :source_id, polymorphic: true, optional: true
  belongs_to :person, optional: true

  has_many :mailing_sents

  xss_terminate only: [:subject, :body], with: :white_list, on: :validation

  after_create do |mailing|
    mailing.schedule
  end

  def schedule
    Delayed::Job.enqueue MailingJob.new(self.id)
  end

  def generate_from
    "#{source.name} <#{if source.is_a? Environment then source.noreply_email else source.contact_email end}>".html_safe
  end

  def generate_subject
    "[%s] %s".html_safe % [source.name, subject]
  end

  def signature_message
    _("Sent by Noosfero.")
  end

  def url
    ""
  end

  def deliver
    each_recipient do |recipient|
      begin
        Mailing::Sender.notification(self, recipient.email).deliver
        self.mailing_sents.create(person: recipient)
      rescue Exception => ex
        Rails.logger.error("#{ex.class.to_s} - #{ex.to_s} at #{__FILE__}:#{__LINE__}")
      end
    end
  end

  class Sender < ApplicationMailer
    def notification(mailing, recipient)
      @message = mailing.body
      @signature_message = mailing.signature_message
      @url = mailing.url
      mail(
        content_type: "text/html",
        to: recipient,
        from: mailing.generate_from,
        reply_to: mailing.person.environment.noreply_email,
        subject: mailing.generate_subject
      )
    end
  end
end
