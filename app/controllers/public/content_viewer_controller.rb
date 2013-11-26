class ContentViewerController < ApplicationController

  needs_profile

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

    @page = FilePresenter.for @page

    unless @page.mime_type == 'text/html' || params[:view]
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

    #FIXME see a better way to do this. It's not need to pass this variable anymore
    @comment = Comment.new
    
    if @page.has_posts?
      posts = if params[:year] and params[:month]
        filter_date = DateTime.parse("#{params[:year]}-#{params[:month]}-01")
        @page.posts.by_range(filter_date..filter_date.at_end_of_month)
      else
        @page.posts
      end

      #FIXME Need to run this before the pagination because this version of
      #      will_paginate returns a will_paginate collection instead of a
      #      relation.
      blog_with_translation = @page.blog? && @page.display_posts_in_current_language?
      posts = posts.native_translations if blog_with_translation

      @posts = posts.paginate({ :page => params[:npage], :per_page => @page.posts_per_page }.merge(Article.display_filter(user, profile)))

      if blog_with_translation
        @posts.replace @posts.map{ |p| p.get_translation_to(FastGettext.locale) }.compact
      end
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

    @comments = @page.comments.without_spam
    @comments = @plugins.filter(:unavailable_comments, @comments)
    @comments_count = @comments.count
    @comments = @comments.without_reply.paginate(:per_page => per_page, :page => params[:comment_page] )

    if params[:slideshow]
      render :action => 'slideshow', :layout => 'slideshow'
    end
  end

  protected

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

  def pass_without_comment_captcha?
    logged_in? && !environment.enabled?('captcha_for_logged_users')
  end
  helper_method :pass_without_comment_captcha?

end
