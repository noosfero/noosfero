class ContentViewerController < ApplicationController

  needs_profile

  before_filter :comment_author, :only => :edit_comment

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
          redirect_to profile.url.merge(:page => page_from_old_path.explode_path)
          return
        end
      end
    end

    if !@page.nil? && !@page.display_to?(user)
      if !profile.public?
        private_profile_partial_parameters
        render :template => 'profile/_private_profile.rhtml', :status => 403
      else #if !profile.visible?
        message = _('You are not allowed to view this content.')
        message += ' ' + _('You can contact the owner of this profile to request access then.')
        render_access_denied(message)
      end
      return
    end

    # page not found, give error
    if @page.nil?
      render_not_found(@path)
      return
    end

    if request.xhr? && params[:toolbar]
      render :partial => 'article_toolbar'
      return
    end

    redirect_to_translation if @page.profile.redirect_l10n

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

    if params[:comment] && params[:confirm] == 'true'
      @comment = Comment.new(params[:comment])
      if request.post? && @page.accept_comments?
        add_comment
      end
    else
      @comment = Comment.new
    end

    if request.post?
      if params[:remove_comment]
        remove_comment
        return
      elsif params[:mark_comment_as_spam]
        mark_comment_as_spam
        return
      end
    end
    
    if @page.has_posts?
      posts = if params[:year] and params[:month]
        filter_date = DateTime.parse("#{params[:year]}-#{params[:month]}-01")
        @page.posts.by_range(filter_date..filter_date.at_end_of_month)
      else
        @page.posts
      end

      if @page.blog? && @page.display_posts_in_current_language?
        posts = posts.native_translations.all(Article.display_filter(user, profile)).map{ |p| p.get_translation_to(FastGettext.locale) }.compact
      end

      @posts = posts.paginate({ :page => params[:npage], :per_page => @page.posts_per_page }.merge(Article.display_filter(user, profile)))
    end

    if @page.folder? && @page.gallery?
      @images = @page.images
      @images = @images.paginate(:per_page => per_page, :page => params[:npage]) unless params[:slideshow]
    end

    @unfollow_form = params[:unfollow] && params[:unfollow] == 'true'
    if params[:unfollow] && params[:unfollow] == 'commit' && request.post?
      @page.followers -= [params[:email]]
      if @page.save
        session[:notice] = _("Notification of new comments to '%s' was successfully canceled") % params[:email]
      end
    end

    comments = @page.comments.without_spam
    @comments = comments.as_thread
    @comments_count = comments.count
    if params[:slideshow]
      render :action => 'slideshow', :layout => 'slideshow'
    end
  end

  def edit_comment
    path = params[:page].join('/')
    @page = profile.articles.find_by_path(path)
    @form_div = 'opened'
    @comment = @page.comments.find_by_id(params[:id])
    if @comment
      if request.post?
        begin
          @comment.update_attributes(params[:comment])
          session[:notice] = _('Comment succesfully updated')
          redirect_to :action => 'view_page', :profile => profile.identifier, :page => @comment.article.explode_path
        rescue
          session[:notice] = _('Comment could not be updated')
        end
      end
    else
      redirect_to @page.view_url
      session[:notice] = _('Could not find the comment in the article')
    end
  end

  protected

  def add_comment
    @comment.author = user if logged_in?
    @comment.article = @page
    @comment.ip_address = request.remote_ip
    @comment.user_agent = request.user_agent
    @comment.referrer = request.referrer
    plugins_filter_comment(@comment)
    return if @comment.rejected?
    if (pass_without_comment_captcha? || verify_recaptcha(:model => @comment, :message => _('Please type the words correctly'))) && @comment.save
      @page.touch
      @comment = nil # clear the comment form
      redirect_to :action => 'view_page', :profile => params[:profile], :page => @page.explode_path, :view => params[:view]
    else
      @form_div = 'opened' if params[:comment][:reply_of_id].blank?
    end
  end

  def plugins_filter_comment(comment)
    @plugins.each do |plugin|
      plugin.filter_comment(comment)
    end
  end

  def pass_without_comment_captcha?
    logged_in? && !environment.enabled?('captcha_for_logged_users')
  end
  helper_method :pass_without_comment_captcha?

  def remove_comment
    @comment = @page.comments.find(params[:remove_comment])
    if (user == @comment.author || user == @page.profile || user.has_permission?(:moderate_comments, @page.profile))
      @comment.destroy
    end
    finish_comment_handling
  end

  def mark_comment_as_spam
    @comment = @page.comments.find(params[:mark_comment_as_spam])
    if logged_in? && (user == @page.profile || user.has_permission?(:moderate_comments, @page.profile))
      @comment.spam!
    end
    finish_comment_handling
  end

  def finish_comment_handling
    if request.xhr?
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      redirect_to :action => 'view_page', :profile => params[:profile], :page => @page.explode_path, :view => params[:view]
    end
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

  def comment_author
    comment = Comment.find_by_id(params[:id])
    if comment
      render_access_denied if comment.author.blank? || comment.author != user
    else
      render_not_found
    end
  end

end
