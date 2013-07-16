class CommentGroupPluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def view_comments
    article_id = params[:article_id]
    group_id = params[:group_id]

    article = profile.articles.find(article_id)
    comments = article.group_comments.without_spam.in_group(group_id)
    render :update do |page|
      page.replace_html "comments_list_group_#{group_id}", :partial => 'comment/comment.rhtml', :collection => comments
      page.replace_html "comment-count-#{group_id}", comments.count
    end
  end

end
