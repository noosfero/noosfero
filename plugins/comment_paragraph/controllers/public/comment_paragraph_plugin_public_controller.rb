class CommentParagraphPluginPublicController < PublicController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def comment_paragraph
    @comment = Comment.find(params[:id])
    render :json => { :paragraph_uuid => @comment.paragraph_uuid }
  end

end
