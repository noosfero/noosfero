class ProfileController < PublicController

  needs_profile
  before_filter :check_access_to_profile, :except => [:join, :refuse_join, :refuse_for_now, :index]
  before_filter :store_before_join, :only => [:join]
  before_filter :login_required, :only => [:join, :refuse_join, :leave, :unblock]

  helper TagsHelper

  def index
    @tags = profile.article_tags
    unless profile.display_info_to?(user)
      profile.visible? ? private_profile : invisible_profile
    end
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

  def tag_feed
    @tag = params[:id]
    tagged = profile.find_tagged_with(@tag).paginate(:per_page => 20, :page => 1)
    feed_writer = FeedWriter.new
    data = feed_writer.write(
      tagged,
      :title => _("%s's contents tagged with \"%s\"") % [profile.name, @tag],
      :description => _("%s's contents tagged with \"%s\"") % [profile.name, @tag],
      :link => url_for(:action => 'tag')
    )
    render :text => data, :content_type => "text/xml"
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
    if is_cache_expired?(profile.members_cache_key(params))
      @members = profile.members.paginate(:per_page => members_per_page, :page => params[:npage])
    end
  end

  def favorite_enterprises
    @favorite_enterprises = profile.favorite_enterprises
  end

  def sitemap
    @articles = profile.top_level_articles
  end

  def join
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
      store_location(request.referer)
      if current_user.person.memberships.include?(profile)
        flash[:notice] = _('You are already a member of "%s"') % profile.name
        redirect_back_or_default profile.url
        return
      end
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

  def unblock
    if current_user.person.is_admin?(profile.environment)
      profile.unblock
      flash[:notice] = _("You have unblocked %s successfully. ") % profile.name
      redirect_to :controller => 'profile', :action => 'index'
    else
      message = _('You are not allowed to unblock enterprises in this environment.')
      render_access_denied(message)
    end
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      redirect_to :action => 'index'
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

  def private_profile
    if profile.person?
      @action = :add_friend
      @message = _("The content here is available to %s's friends only." % profile.short_name)
    else
      @action = :join
      @message = _('The contents in this community is available to members only.')
    end
    @no_design_blocks = true
  end

  def invisible_profile
    render_access_denied(_("Sorry, this profile was defined as private by its owner. You'll not be able to view content here unless the profile owner adds adds you."), _("Oops ... you cannot go ahead here"))
  end

  def per_page
    Noosfero::Constants::PROFILE_PER_PAGE
  end

  def members_per_page
    20
  end

end
