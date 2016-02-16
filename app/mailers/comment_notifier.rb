class CommentNotifier < ApplicationMailer

  def notification(comment)
    profile = comment.article.profile
    self.environment = profile.environment
    @recipient = profile.nickname || profile.name
    @sender = comment.author_name
    @sender_link = comment.author_link
    @article_title = comment.article.name
    @comment_url = comment.url
    @comment_title = comment.title
    @comment_body = comment.body
    @url = profile.environment.top_url

    mail(
      to: comment.notification_emails,
      from: "#{profile.environment.name} <#{profile.environment.noreply_email}>",
      subject: _("[%s] you got a new comment!") % [profile.environment.name]
    )
  end

  def mail_to_followers(comment, emails)
    profile = comment.article.profile
    self.environment = profile.environment

    @recipient = profile.nickname || profile.name
    @sender = comment.author_name
    @sender_link = comment.author_link
    @article_title = comment.article.name
    @comment_url = comment.url
    @unsubscribe_url = comment.article.view_url.merge({:unfollow => true})
    @comment_title = comment.title
    @comment_body = comment.body
    @url = profile.environment.top_url

    mail(
      bcc: emails,
      from: "#{profile.environment.name} <#{profile.environment.noreply_email}>",
      subject: _("[%s] %s commented on a content of %s") % [profile.environment.name, comment.author_name, profile.short_name]
    )
  end
end
