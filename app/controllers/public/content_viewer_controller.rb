class ContentViewerController < PublicController

  needs_profile

  def view_page
    path = params[:page].join('/')

    if path.blank?
      @page = profile.home_page
      if @page.nil?
        render :action => 'no_home_page'
      end
    else
      @page = profile.articles.find_by_path(path)
      if @page.nil?
        render_not_found(@path)
      end
    end
  end

end
