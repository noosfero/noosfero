class AntiSpamPlugin < Noosfero::Plugin

  def self.plugin_name
    "AntiSpam"
  end

  def self.plugin_description
    _("Tests comments and suggested articles against a spam checking service compatible with the Akismet API")
  end

  def self.host_default_setting
    'api.antispam.typepad.com'
  end

  def check_comment_for_spam(comment)
    if rakismet_call AntiSpamPlugin::CommentWrapper.new(comment), comment.environment, :spam?
      comment.spam = true
      comment.save!
    end
  end

  def comment_marked_as_spam(comment)
    rakismet_call AntiSpamPlugin::CommentWrapper.new(comment), comment.environment, :spam!
  end

  def comment_marked_as_ham(comment)
    rakismet_call AntiSpamPlugin::CommentWrapper.new(comment), comment.environment, :ham!
  end

  def check_suggest_article_for_spam(suggest_article)
    if rakismet_call AntiSpamPlugin::SuggestArticleWrapper.new(suggest_article), suggest_article.environment, :spam?
      suggest_article.spam = true
      suggest_article.save!
    end
  end

  def suggest_article_marked_as_spam(suggest_article)
    rakismet_call AntiSpamPlugin::SuggestArticleWrapper.new(suggest_article), suggest_article.environment, :spam!
  end

  def suggest_article_marked_as_ham(suggest_article)
    rakismet_call AntiSpamPlugin::SuggestArticleWrapper.new(suggest_article), suggest_article.environment, :ham!
  end

  protected

  def rakismet_call(submission, environment, op)
    settings = Noosfero::Plugin::Settings.new(environment, self.class)

    Rakismet.host = settings.host
    Rakismet.key = settings.api_key
    Rakismet.url = environment.top_url

    submission.send(op)
  end

end
