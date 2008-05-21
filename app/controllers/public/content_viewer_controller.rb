class ContentViewerController < PublicController

  needs_profile

  inverse_captcha :field => 'e_mail'

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

    if !@page.display_to?(user)
      render :action => 'access_denied', :status => 403
    end

    if @page.mime_type != 'text/html'
      headers['Content-Type'] = @page.mime_type
      data = @page.data

      # TODO test the condition
      if data.nil?
        raise "No data for file"
      end

      render :text => data, :layout => false
      return
    end

    if request.post? && params[:comment] && params[self.icaptcha_field].blank?
      add_comment
    end

    if request.post? && params[:remove_comment]
      remove_comment
    end
    
    @comments = @page.comments(true)
  end

  protected

  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.author = user if logged_in?
    @comment.article = @page
    if @comment.save
      @comment = nil # clear the comment form
    else
      @form_div = 'opened'
    end
  end

  def remove_comment
    @comment = @page.comments.find(params[:remove_comment])
    if (user == @comment.author) || (user == @page.profile)
      @comment.destroy
      flash[:notice] = _('Comment succesfully deleted')
    end
    redirect_to :action => 'view_page'
  end

end
