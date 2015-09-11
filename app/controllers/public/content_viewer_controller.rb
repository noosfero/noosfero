require 'diffy'

class ContentViewerController < ApplicationController

  needs_profile

  helper ProfileHelper
  helper TagsHelper

  def view_page

    path = get_path(params[:page], params[:format])

    @version = params[:version].to_i
    @npage = params[:npage] || '1'

    if path.blank?
      @page = profile.home_page
      return if redirected_to_profile_index
    else
      @page = profile.articles.find_by_path(path)
      return if redirected_page_from_old_path(path)
    end

    return unless allow_access_to_page(path)

    if @version > 0
      return render_access_denied unless @page.display_versions?
      return if rendered_versioned_article
    end

    redirect_to_translation and return if @page.profile.redirect_l10n

    if request.post? && @page.forum?
      process_forum_terms_of_use(user, params[:terms_accepted])
    elsif is_a_forum_topic?(@page) && !@page.parent.agrees_with_terms?(user)
      redirect_to @page.parent.url
      return
    end

    # At this point the page will be showed
    @page.hit unless user_is_a_bot? || already_visited?(@page)

    @page = FilePresenter.for @page

    return if rendered_file_download(params[:view])

    @form_div = params[:form]

    #FIXME see a better way to do this. It's not need to pass this variable anymore
    @comment = Comment.new

    process_page_posts(params)

    if @page.folder? && @page.gallery?
      @images = get_images(@page, params[:npage], params[:slideshow])
    end

    process_page_followers(params)

    process_comments(params)

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
    path = params[:page]
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
            return true
          end
        end
      end
    end
    false
  end

  def pass_without_comment_captcha?
    logged_in? && !environment.enabled?('captcha_for_logged_users')
  end
  helper_method :pass_without_comment_captcha?

  def allow_access_to_page(path)
    if @page.nil? # page not found, give error
      render_not_found(path)
      return false
    end

    unless @page.display_to?(user)
      if !profile.visible? || profile.secret? || (user && user.follows?(profile)) || user.blank?
        render_access_denied
      else #!profile.public?
        private_profile_partial_parameters
        render :template => 'profile/_private_profile', :status => 403, :formats => [:html]
      end

      return false
    end

    return true
  end

  def user_is_a_bot?
    user_agent= request.env["HTTP_USER_AGENT"]
    user_agent.blank? ||
    user_agent.match(/bot/) ||
    user_agent.match(/spider/) ||
    user_agent.match(/crawler/) ||
    user_agent.match(/\(.*https?:\/\/.*\)/)
  end

  def get_path(page, format = nil)
    path = page
    path = path.join('/') if path.kind_of?(Array)
    path = "#{path}.#{format}" if format

    return path
  end

  def redirected_to_profile_index
    if @page.nil?
      redirect_to :controller => 'profile', :action => 'index', :profile => profile.identifier
      return true
    end

    return false
  end

  def redirected_page_from_old_path(path)
    unless @page
      page_from_old_path = profile.articles.find_by_old_path(path)
      if page_from_old_path
        redirect_to profile.url.merge(:page => page_from_old_path.explode_path)
        return true
      end
    end

    return false
  end

  def process_forum_terms_of_use(user, terms_accepted = nil)
    if @page.forum? && @page.has_terms_of_use && terms_accepted == "true"
      @page.add_agreed_user(user)
    end
  end

  def is_a_forum_topic? (page)
    return (!@page.parent.nil? && @page.parent.forum?)
  end

  def rendered_versioned_article
    @versioned_article = @page.versions.find_by_version(@version)
    if @versioned_article && @page.versions.latest.version != @versioned_article.version
      render :template => 'content_viewer/versioned_article.html.erb'
      return true
    end

    return false
  end

  def rendered_file_download(view = nil)
    if @page.download? view
      headers['Content-Type'] = @page.mime_type
      headers.merge! @page.download_headers
      data = @page.data

      # TODO test the condition
      if data.nil?
        raise "No data for file"
      end

      render :text => data, :layout => false
      return true
    end

    return false
  end

  def process_page_posts(params)
    if @page.has_posts?
      posts = get_posts(params[:year], params[:month])

      #FIXME Need to run this before the pagination because this version of
      #      will_paginate returns a will_paginate collection instead of a
      #      relation.
      posts = posts.native_translations if blog_with_translation?(@page)

      @posts = posts.display_filter(user, profile).paginate({ :page => params[:npage], :per_page => @page.posts_per_page }).to_a

      if blog_with_translation?(@page)
        @posts.replace @posts.map{ |p| p.get_translation_to(FastGettext.locale) }.compact
      end
    end
  end

  def get_posts(year = nil, month = nil)
    if year && month
      filter_date = DateTime.parse("#{year}-#{month}-01")
      return @page.posts.by_range(filter_date..filter_date.at_end_of_month)
    else
      return @page.posts
    end
  end

  def blog_with_translation?(page)
    return (page.blog? && page.display_posts_in_current_language?)
  end

  def get_images(page, npage, slideshow)
    images = page.images.select{ |a| a.display_to? user }
    images = images.paginate(:per_page => per_page, :page => npage) unless slideshow

    return images
  end

  def process_page_followers(params)
    @unfollow_form = params[:unfollow] == 'true'
    if params[:unfollow] == 'commit' && request.post?
      @page.followers -= [params[:email]]
      if @page.save
        session[:notice] = _("Notification of new comments to '%s' was successfully canceled") % params[:email]
      end
    end
  end

  def process_comments(params)
    @comments = @page.comments.without_spam
    @comments = @plugins.filter(:unavailable_comments, @comments)
    @comments_count = @comments.count
    @comments = @comments.without_reply.paginate(:per_page => per_page, :page => params[:comment_page] )
    @comment_order = params[:comment_order].nil? ? 'oldest' : params[:comment_order]
  end

  private

  def already_visited?(element)
    user_id = if user.nil? then -1 else current_user.id end
    user_id = "#{user_id}_#{element.id}_#{element.class}"

    if cookies.signed[:visited] == user_id
      return true
    else
      cookies.permanent.signed[:visited] = user_id
      return false
    end
  end

end
