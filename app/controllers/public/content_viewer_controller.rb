class ContentViewerController < PublicController

  needs_profile

  def view_page
    path = params[:page].join('/')

    if path.blank?
      @page = profile.home_page
      if @page.nil?
        render :action => 'no_home_page'
        return
      end
    else
      @page = profile.articles.find_by_path(path)
      if @page.nil?
        render_not_found(@path)
        return
      end
    end

    if @page.mime_type != 'text/html'
      headers['Content-Type'] = @page.mime_type
      render :text => @page.data, :layout => false
      return
    end

    if request.post? && params[:comment]
      @comment = Comment.new(params[:comment])
      @comment.author = user if logged_in?
      @comment.article = @page
      if @comment.save!
        @comment = nil # clear the comment form
      end
    end
    @comments = @page.comments(true)
  end

end
