class CommentParagraphPluginMyprofileController < MyProfileController

  before_filter :check_permission

  def toggle_activation
    @article.comment_paragraph_plugin_activate = !@article.comment_paragraph_plugin_activate
    @article.save!
    redirect_to @article.view_url
  end

  protected

  def check_permission
    @article = profile.articles.find(params[:id])
    render_access_denied unless @article.comment_paragraph_plugin_enabled? && @article.allow_edit?(user)
  end

end
