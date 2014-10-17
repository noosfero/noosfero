class WorkAssignmentPluginCmsController < CmsController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def destroy
    @article = profile.articles.find(params[:id])
    if request.post?
      @article.destroy
      session[:notice] = _("\"#{@article.name}\" was removed.")
      referer = Rails.application.routes.recognize_path URI.parse(request.referer).path rescue nil
      redirect_to referer
    end
  end
end