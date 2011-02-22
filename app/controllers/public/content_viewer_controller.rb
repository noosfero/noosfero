class ContentViewerController < ApplicationController

  needs_profile

  inverse_captcha :field => 'e_mail'

  helper ProfileHelper
  helper TagsHelper

  def view_page
    path = params[:page].join('/')

    if path.blank?
      @page = profile.home_page
      if @page.nil?
        redirect_to :controller => 'profile', :action => 'index', :profile => profile.identifier
        return
      end
    else
      @page = profile.articles.find_by_path(path)
      unless @page
        page_from_old_path = profile.articles.find_by_old_path(path)
        if page_from_old_path
          redirect_to :profile => profile.identifier, :page => page_from_old_path.explode_path
          return
        end
      end

      # page not found, give error
      if @page.nil?
        render_not_found(@path)
        return
      end
    end

    if !@page.public? && !request.ssl?
      return if redirect_to_ssl
    end

    if @page.public?
      return unless avoid_ssl
    end

    if !@page.display_to?(user)
      if profile.display_info_to?(user) || !profile.visible?
        message = _('You are not allowed to view this content. You can contact the owner of this profile to request access then.')
        render_access_denied(message)
      elsif !profile.public?
        redirect_to :controller => 'profile', :action => 'index', :profile => profile.identifier
      end
      return
    end

    redirect_to_translation

    # At this point the page will be showed
    @page.hit

    unless @page.mime_type == 'text/html' || (@page.image? && params[:view])
      headers['Content-Type'] = @page.mime_type
      data = @page.data

      # TODO test the condition
      if data.nil?
        raise "No data for file"
      end

      render :text => data, :layout => false
      return
    end

    @form_div = params[:form]

    if request.post? && params[:comment] && params[self.icaptcha_field].blank? && params[:confirm] == 'true' && @page.accept_comments?
      add_comment
    end

    if request.post? && params[:remove_comment]
      remove_comment
    end
    
    if @page.has_posts?
      posts = if params[:year] and params[:month]
        filter_date = DateTime.parse("#{params[:year]}-#{params[:month]}-01")
        @page.posts.by_range(filter_date..filter_date.at_end_of_month)
      else
        @page.posts
      end

      posts = posts.native_translations if @page.blog? && @page.display_posts_in_current_language?

      @posts = posts.paginate({ :page => params[:npage], :per_page => @page.posts_per_page }.merge(Article.display_filter(user, profile)))

      @posts.map!{ |p| p.get_translation_to(FastGettext.locale) } if @page.blog? && @page.display_posts_in_current_language?
    end

    if @page.folder? && @page.gallery?
      @images = @page.images
      @images = @images.paginate(:per_page => per_page, :page => params[:npage]) unless params[:slideshow]
    end

    @comments = @page.comments(true).as_thread
    @comments_count = @page.comments.count
    if params[:slideshow]
      render :action => 'slideshow', :layout => 'slideshow'
    end
  end

  protected

  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.author = user if logged_in?
    @comment.article = @page
    if @comment.save
      @page.touch
      @comment = nil # clear the comment form
      redirect_to :action => 'view_page', :profile => params[:profile], :page => @page.explode_path, :view => params[:view]
    else
      @form_div = 'opened' if params[:comment][:reply_of_id].blank?
    end
  end

  def remove_comment
    @comment = @page.comments.find(params[:remove_comment])
    if (user == @comment.author || user == @page.profile || user.has_permission?(:moderate_comments, @page.profile))
      @comment.destroy
      session[:notice] = _('Comment succesfully deleted')
    end
    redirect_to :action => 'view_page', :profile => params[:profile], :page => @page.explode_path, :view => params[:view]
  end

  def per_page
    12
  end

  def redirect_to_translation
    locale = FastGettext.locale
    if !@page.language.nil? && @page.language != locale
      translations = [@page.native_translation] + @page.native_translation.translations
      urls = translations.map{ |t| URI.parse(url_for(t.url)).path }
      urls << URI.parse(url_for(profile.admin_url.merge({ :controller => 'cms', :action => 'edit', :id => @page.id }))).path
      urls << URI.parse(url_for(profile.admin_url.merge(:controller => 'cms', :action => 'new'))).path
      referer = URI.parse(url_for(request.referer)).path unless request.referer.blank?
      unless urls.include?(referer)
        translations.each do |translation|
          if translation.language == locale
            @page = translation
            redirect_to :profile => @page.profile.identifier, :page => @page.explode_path
          end
        end
      end
    end
  end

end
