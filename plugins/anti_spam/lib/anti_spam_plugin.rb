class AntiSpamPlugin < Noosfero::Plugin

  def self.plugin_name
    "AntiSpam"
  end

  def self.plugin_description
    _("Checks comments against a spam checking service compatible with the Akismet API")
  end

  def check_comment_for_spam(comment)
    if rakismet_call(comment, :spam?)
      comment.spam = true
      comment.save!
    end
  end

  def comment_marked_as_spam(comment)
    rakismet_call(comment, :spam!)
  end

  def comment_marked_as_ham(comment)
    rakismet_call(comment, :ham!)
  end

  protected

  def rakismet_call(comment, op)
    settings = AntiSpamPlugin::Settings.new(comment.environment)

    Rakismet.host = settings.host
    Rakismet.key = settings.api_key
    Rakismet.url = comment.environment.top_url

    submission = AntiSpamPlugin::CommentWrapper.new(comment)
    submission.send(op)
  end

end
