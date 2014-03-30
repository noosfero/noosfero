class MarkCommentAsReadPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def mark_as_read
    comment = Comment.find(params[:id])
    comment.mark_as_read(user)
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

  def mark_as_not_read
    comment = Comment.find(params[:id])
    comment.mark_as_not_read(user)
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

end
