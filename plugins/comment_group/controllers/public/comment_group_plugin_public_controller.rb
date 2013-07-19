class CommentGroupPluginPublicController < PublicController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def comment_group
    render :json => { :group_id => Comment.find(params[:id]).group_id }
  end

end
