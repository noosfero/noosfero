class CommentHandler < Struct.new(:comment_id, :method)

  def perform
    comment = Comment.find(comment_id)
    comment.send(method)
  rescue ActiveRecord::RecordNotFound
    # just ignore non-existing comments
  end

end
