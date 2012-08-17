class CommentHandler < Struct.new(:comment_id)

  def perform
    comment = Comment.find(comment_id)
    comment.notify_by_mail
  rescue ActiveRecord::RecordNotFound
    # just ignore non-existing comments
  end

end
