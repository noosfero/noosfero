class ContentViewerController < PublicController

  needs_profile

  def view_page
    path = params[:page].clone
    path.unshift(params[:profile])
    @path = path.join('/')
    @page = Article.find_by_path(@path)
    if @page.nil?
      render :action => 'not_found', :status => 404
    end
  end

end
