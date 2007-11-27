class ContentViewerController < PublicController

  needs_profile

  def view_page
    path = params[:page].join('/')

    if path.blank?
      @page = profile.home_page
      # FIXME need to do something when the user didn't set a homepage
    else
      @page = profile.articles.find_by_path(path)
    end

    if @page.nil?
      render_not_found(@path)
    end
  end

end
