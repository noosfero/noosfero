require 'diffy'

class ContentViewerController < ApplicationController

  needs_profile

  helper ProfileHelper
  helper TagsHelper

  def view_page
    path = params[:page]
    path = path.join('/') if path.kind_of?(Array)
    path = "#{path}.#{params[:format]}" if params[:format]
    @version = params[:version].to_i

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

    return unless allow_access_to_page(path)

    if @version > 0
      return render_access_denied unless @page.display_versions?
      @versioned_article = @page.versions.find_by_version(@version)
      if @versioned_article && @page.versions.latest.version != @versioned_article.version
        render :template => 'content_viewer/versioned_article.html.erb'
        return
      end
    end

    redirect_to_translation and return if @page.profile.redirect_l10n

    if request.post?
      if @page.forum? && @page.has_terms_of_use && params[:terms_accepted] == "true"
        @page.add_agreed_user(user)
      end
    elsif !@page.parent.nil? && @page.parent.forum?
      unless @page.parent.agrees_with_terms?(user)
        redirect_to @page.parent.url
      end
    end

    # At this point the page will be showed
    @page.hit unless user_is_a_bot?

    @page = FilePresenter.for @page

    if @page.download? params[:view]
      headers['Content-Type'] = @page.mime_type
      headers.merge! @page.download_headers
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

      @posts = posts.paginate({ :page => params[:npage], :per_page => @page.posts_per_page }.merge(Article.display_filter(user, profile))).to_a

      if blog_with_translation
        @posts.replace @posts.map{ |p| p.get_translation_to(FastGettext.locale) }.compact
      end
    end

    if @page.folder? && @page.gallery?
      @images = @page.images.select{ |a| a.display_to? user }
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
    @comment_order = params[:comment_order].nil? ? 'oldest' : params[:comment_order]

    if request.xhr? and params[:comment_order]
      if @comment_order == 'newest'
        @comments = @comments.reverse
      end

      return render :partial => 'comment/comment', :collection => @comments
    end

    if params[:slideshow]
      render :action => 'slideshow', :layout => 'slideshow'
      return
    end
    render :view_page, :formats => [:html]
  end

  def versions_diff
    path = params[:page].join('/')
    @page = profile.articles.find_by_path(path)
    @v1, @v2 = @page.versions.find_by_version(params[:v1]), @page.versions.find_by_version(params[:v2])
  end

  def article_versions
    path = params[:page]
    @page = profile.articles.find_by_path(path)
    return unless allow_access_to_page(path)

    render_access_denied unless @page.display_versions?
    @versions = @page.versions.paginate(:per_page => per_page, :page => params[:npage])
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

  def allow_access_to_page(path)
    allowed = true
    if @page.nil? # page not found, give error
      render_not_found(path)
      allowed = false
    elsif !@page.display_to?(user)
      if !profile.public?
        private_profile_partial_parameters
        render :template => 'profile/_private_profile', :status => 403
        allowed = false
      else #if !profile.visible?
        render_access_denied
        allowed = false
      end
    end
    allowed
  end

  def user_is_a_bot?
    user_agent= request.env["HTTP_USER_AGENT"]
    user_agent.blank? ||
    user_agent.match(/bot/) ||
    user_agent.match(/spider/) ||
    user_agent.match(/crawler/) ||
    user_agent.match(/\(.*https?:\/\/.*\)/)
  end
end
