# encoding: utf-8

require 'mail'

class MailingListPlugin::EmailReply
  @queue = :email_replies

  LOG_PATH = File.dirname(__FILE__) + '/../../log/email_replys.log'

  def initialize(content)
    begin
      mail  = Mail.read_from_string(content.force_encoding('utf-8'))
      from  = mail.from.first
      uuid = mail.header['In-Reply-To']
      uuid = uuid.decoded if uuid.present?
      uuid = uuid.gsub('<','').split('@')[0] if uuid.present?


      if mail.multipart?
        part = mail.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
        unless part.nil?
          message = part.body.decoded
        end
      else
        message = mail.body.decoded
      end

      if message.present? && uuid.present?
        Delayed::Job.enqueue(MailingListPlugin::ProcessReplyJob.new(from, uuid, message))
      end
    rescue Exception => ex
      f = File.open(LOG_PATH, 'w+')
      f.write("\n" + ex.message + "\n")
      f.write(ex.backtrace.join("\n") + "\n")
      f.close
      return
    end
  end
end
