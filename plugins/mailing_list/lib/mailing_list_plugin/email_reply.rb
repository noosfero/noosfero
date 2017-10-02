# encoding: utf-8

require 'mail'

class MailingListPlugin::EmailReply
  @queue = :email_replies

  LOG_PATH = File.dirname(__FILE__) + '/../../../../log/mailing_list/email_replies.log'

  def initialize(content)
    begin
      content.encode!('UTF-8', content.encoding, :invalid => :replace, :replace => '')
      mail  = Mail.read_from_string(content)
      from  = mail.from.first
      message_uuid = mail.header['Message-Id']
      message_uuid = message_uuid.decoded if message_uuid.present?
      message_uuid = message_uuid.gsub(/[<>]/,'') if message_uuid.present?
      reply_uuid = mail.header['In-Reply-To']
      reply_uuid = reply_uuid.decoded if reply_uuid.present?
      reply_uuid = reply_uuid.gsub(/[<>]/,'') if reply_uuid.present?


      if mail.multipart?
        part = mail.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
        unless part.nil?
          message = part.body.decoded
        end
      else
        message = mail.body.decoded
      end

      if message.present? && message_uuid.present? && reply_uuid.present?
        Delayed::Job.enqueue(MailingListPlugin::ProcessReplyJob.new(from, message_uuid, reply_uuid, message))
      end
    rescue Exception => ex
      f = File.open(LOG_PATH, 'a')
      time = Time.now.to_s
      f.write("===  #{time}  ===")
      f.write("\n" + ex.message + "\n")
      f.write(ex.backtrace.join("\n") + "\n")
      f.write("===  #{time}  ===")
      f.close
      return
    end
  end
end
