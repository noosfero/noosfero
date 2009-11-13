class ProfileController < PublicController

  needs_profile
  before_filter :check_access_to_profile
  before_filter :store_before_join, :only => [:join]
  before_filter :login_required, :only => [:join, :refuse_join, :leave]

  helper TagsHelper

  def index
    @tags = profile.article_tags
  end

  def tags
    @tags_cache_key = "tags_profile_#{profile.id.to_s}"
    if is_cache_expired?(@tags_cache_key, true)
      @tags = profile.article_tags
    end
  end

  def tag
    @tag = params[:id]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_#{profile.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key, true)
      @tagged = profile.find_tagged_with(@tag).paginate(:per_page => 20, :page => params[:npage])
    end
  end

  def communities
    if is_cache_expired?(profile.communities_cache_key(params))
      @communities = profile.communities.paginate(:per_page => per_page, :page => params[:npage])
    end
  end

  def enterprises
    @enterprises = profile.enterprises
  end

  def friends
    if is_cache_expired?(profile.friends_cache_key(params))
      @friends = profile.friends.paginate(:per_page => per_page, :page => params[:npage])
    end
  end

  def members
    @members = profile.members
  end

  def favorite_enterprises
    @favorite_enterprises = profile.favorite_enterprises
  end

  def sitemap
    @articles = profile.top_level_articles
  end

  def join
    store_location(request.referer)
    @wizard = params[:wizard]
    if request.post? && params[:confirmation]
      profile.add_member(current_user.person)
      flash[:notice] = _('%s administrator still needs to accept you as member.') % profile.name if profile.closed?
      if @wizard
        redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
      else
        redirect_to_before_join
      end
    else
      if request.xhr?
        render :layout => false
      end
    end
  end

  def leave
    @wizard = params[:wizard]
    if request.post? && params[:confirmation]
      profile.remove_member(current_user.person)
      if @wizard
        redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
      else
        redirect_back_or_default profile.url
      end
    else
      store_location(request.referer)
      if request.xhr?
        render :layout => false
      end
    end
  end

  def refuse_join
    p = current_user.person
    p.refused_communities << profile
    p.save
    redirect_to profile.url
  end

  def refuse_for_now
    session[:no_asking] ||= []
    session[:no_asking].shift if session[:no_asking].size >= 10
    session[:no_asking] << profile.id
    render :text => '', :layout => false
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      render :action => 'private_profile', :status => 403, :layout => false
    end
  end

  def store_before_join
    session[:before_join] = request.referer unless logged_in?
  end

  def redirect_to_before_join
    back = session[:before_join]
    if back
      session[:before_join] = nil
      redirect_to back
    else
      redirect_back_or_default profile.url
    end
  end

  def per_page
    Noosfero::Constants::PROFILE_PER_PAGE
  end
end
