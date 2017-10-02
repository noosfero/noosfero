class MailingListPlugin::ProcessReplyJob < Struct.new(:from, :message_uuid, :reply_uuid, :message)
  def perform
    log_email_reception

    return log('Empty message!') if message.blank?

    author = User.find_by_email(from).try(:person)
    return log('Unknown user!') if author.blank?

    return log('Empty Message UUID!') if message_uuid.blank?
    return log('Empty Reply UUID!') if reply_uuid.blank?

    uuid_reply = Comment.with_plugin_metadata(MailingListPlugin, {uuid: reply_uuid}).first
    uuid_reply = Article.with_plugin_metadata(MailingListPlugin, {uuid: reply_uuid}).first if uuid_reply.blank?
    if uuid_reply.blank?
      article = nil
    elsif uuid_reply.kind_of?(Article)
      reply_of_id = nil
      article = uuid_reply
    else
      reply_of_id = uuid_reply.id
      article = uuid_reply.article
    end

    return log("Unknown referenced content [#{reply_uuid}]!") if article.blank?
    return log('Article does not accept comments!') if !article.accept_comments?

    environment_settings = Noosfero::Plugin::Settings.new article.environment, MailingListPlugin
    administrator_email = environment_settings.administrator_email
    # Avoids the loop: receive email reply -> create comment -> send message to the list -> receive email reply
    return log("Ignore email from us [#{administrator_email}]") if from == administrator_email

    reply_address = "#{uuid_reply.author_name} <#{uuid_reply.author.email}>"
    comment = Comment.new(
      body: treat_body(message, reply_address),
      author: author, source: article, reply_of_id: reply_of_id,
      mailing_list_plugin_uuid: message_uuid, mailing_list_plugin_from_list: true)
    article.plugins.dispatch(:filter_comment, comment)

    begin
      if !comment.rejected? && comment.valid?
        if comment.need_moderation?
          ApproveComment.create!(:requestor => comment.author, :target => article.profile, :comment_attributes => comment.attributes.to_json)
          log('ApproveComment task created!')
        else
          comment.save!
          comment_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin
          comment_metadata.uuid = message_uuid
          comment_metadata.save!
          log('Comment created!')
        end
      end
    rescue Exception => exception
      log_creation_error(exception)
    end
  end

  private

  def log(message)
    logger = Delayed::Worker.logger
    logger.info("== [MailingListPlugin] #{message}")
  end

  def log_creation_error(exception)
      logger = Delayed::Worker.logger
      logger.error('== [MailingListPlugin] Comment creation failed!')
      logger.error(exception.message)
      logger.error(exception.backtrace)
  end

  def log_email_reception
    logger = Delayed::Worker.logger
    logger.info("== [MailingListPlugin] Received email!")
    logger.info("From: %s" % from)
    logger.info("Message UUID: %s" % message_uuid)
    logger.info("Reply UUID: %s" % reply_uuid)
    logger.info("Message:\n\n%s" % message)
    logger.info("==")
  end

  def treat_body(body, address)
    body = remove_quotes(body, address)
    body = remove_signature(body)
  end

  def remove_signature(body)
    if body =~ /^-- $/
      body = body.split('-- ')[0..-2].join('-- ')
    end

    body
  end

  def remove_quotes(body, address)
    regex_arr = [
      Regexp.new("#{s_('email-reply|From')}:\s*" + Regexp.escape(address), Regexp::IGNORECASE),
      Regexp.new("<" + Regexp.escape(address) + ">", Regexp::IGNORECASE),
      Regexp.new(Regexp.escape(address) + "\s+#{s_('email-reply|wrote')}:", Regexp::IGNORECASE),
      Regexp.new("^.*#{s_('email-reply|On')}.*(\n)?#{s_('email-reply|wrote')}:$", Regexp::IGNORECASE),
      Regexp.new("-+#{s_('email-reply|original')}\s+#{s_('email-reply|message')}-+\s*$", Regexp::IGNORECASE),
      Regexp.new("#{s_('email-reply|from')}:\s*$", Regexp::IGNORECASE)
    ]

    body_length = body.length
    #calculates the matching regex closest to top of page
    index = regex_arr.inject(body_length) do |min, regex|
        [(body.index(regex) || body_length), min].min
    end

    body[0, index].strip
  end
end
