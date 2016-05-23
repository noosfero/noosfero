class CommentHandler < Struct.new(:comment_id, :method, :locale)
  def initialize(*args)
    super
    self.locale ||= FastGettext.locale
  end

  def perform
    saved_locale = FastGettext.locale
    FastGettext.locale = locale

    comment = Comment.find(comment_id)
    comment.send(method)
    FastGettext.locale = saved_locale
  rescue ActiveRecord::RecordNotFound
    # just ignore non-existing comments
  end

end
