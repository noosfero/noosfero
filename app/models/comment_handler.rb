class CommentHandler < Struct.new(:comment_id)

  def perform
    comment = Comment.find(comment_id)
    comment.verify_and_notify
  rescue ActiveRecord::RecordNotFound
    # just ignore non-existing comments
  end

end
