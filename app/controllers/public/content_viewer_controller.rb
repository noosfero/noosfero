class ContentViewerController < PublicController

  needs_profile

  def view_page
    path = params[:page].join('/')

    if path.blank?
      @page = profile.home_page
    else
      @page = profile.articles.find_by_path(path)
    end

    if @page.nil?
      render_not_found(@path)
    end
  end

end
