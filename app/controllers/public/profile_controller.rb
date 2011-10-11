class ProfileController < PublicController

  needs_profile
  before_filter :check_access_to_profile, :except => [:join, :join_not_logged, :index, :add]
  before_filter :store_location, :only => [:join, :join_not_logged, :report_abuse]
  before_filter :login_required, :only => [:add, :join, :join_not_logged, :leave, :unblock, :leave_scrap, :remove_scrap, :remove_activity, :view_more_scraps, :view_more_activities, :view_more_network_activities, :report_abuse, :register_report]

  helper TagsHelper

  def index
    @activities = @profile.tracked_actions.paginate(:per_page => 30, :page => params[:page])
    @wall_items = []
    @network_activities = !@profile.is_a?(Person) ? @profile.tracked_notifications.paginate(:per_page => 30, :page => params[:page]) : []
    if logged_in? && current_person.follows?(@profile)
      @network_activities = @profile.tracked_notifications.paginate(:per_page => 30, :page => params[:page]) if @network_activities.empty?
      @wall_items = @profile.scraps_received.not_replies.paginate(:per_page => 30, :page => params[:page])
    end
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

  def content_tagged
    @tag = params[:id]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_#{profile.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key, true)
      @tagged = profile.find_tagged_with(@tag).paginate(:per_page => 20, :page => params[:npage])
    end
  end

  def tag_feed
    @tag = params[:id]
    tagged = profile.articles.paginate(:per_page => 20, :page => 1, :order => 'published_at DESC', :include => :tags, :conditions => ['tags.name LIKE ?', @tag])
    feed_writer = FeedWriter.new
    data = feed_writer.write(
      tagged,
      :title => _("%s's contents tagged with \"%s\"") % [profile.name, @tag],
      :description => _("%s's contents tagged with \"%s\"") % [profile.name, @tag],
      :link => url_for(profile.url)
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

  def fans
    @fans = profile.fans
  end

  def favorite_enterprises
    @favorite_enterprises = profile.favorite_enterprises
  end

  def sitemap
    @articles = profile.top_level_articles
  end

  def join
    if !user.memberships.include?(profile)
      profile.add_member(user)
      if !profile.members.include?(user)
        render :text => {:message => _('%s administrator still needs to accept you as member.') % profile.name}.to_json
      else
        render :text => {:message => _('You just became a member of %s.') % profile.name}.to_json
      end
    else
      render :text => {:message => _('You are already a member of %s.') % profile.name}.to_json
    end
  end

  def join_not_logged
    if request.post?
      profile.add_member(user)
      session[:notice] = _('%s administrator still needs to accept you as member.') % profile.name if profile.closed?
      redirect_to_previous_location
    else
      if user.memberships.include?(profile)
        session[:notice] = _('You are already a member of %s.') % profile.name
        redirect_to profile.url
        return
      end
      if request.xhr?
        render :layout => false
      else
        redirect_to profile.url
      end
    end
  end

  def leave
    if current_person.memberships.include?(profile)
      if current_person.is_last_admin?(profile)
        render :text => {:redirect_to => url_for({:controller => 'profile_members', :action => 'last_admin', :person => current_person.id})}.to_json
      else
        render :text => current_person.leave(profile, params[:reload])
      end
    else
      render :text => {:message => _('You are not a member of %s.') % profile.name}.to_json
    end
  end

  def check_membership
    unless logged_in?
      render :text => ''
      return
    end
    if user.memberships.include?(profile)
      render :text => 'true'
    else
      render :text => 'false'
    end
  end

  def add
    # FIXME this shouldn't be in Person model?
    if !user.memberships.include?(profile)
      AddFriend.create!(:person => user, :friend => profile)
      render :text => _('%s still needs to accept being your friend.') % profile.name
    else
      render :text => _('You are already a friend of %s.') % profile.name
    end
  end

  def check_friendship
    unless logged_in?
      render :text => ''
      return
    end
    if user == profile || user.already_request_friendship?(profile) || user.is_a_friend?(profile)
      render :text => 'true'
    else
      render :text => 'false'
    end
  end

  def unblock
    if current_user.person.is_admin?(profile.environment)
      profile.unblock
      session[:notice] = _("You have unblocked %s successfully. ") % profile.name
      redirect_to :controller => 'profile', :action => 'index'
    else
      message = __('You are not allowed to unblock enterprises in this environment.')
      render_access_denied(message)
    end
  end

  def leave_scrap
    sender = params[:sender_id].nil? ? current_user.person : Person.find(params[:sender_id])
    receiver = params[:receiver_id].nil? ? @profile : Person.find(params[:receiver_id])
    @scrap = Scrap.new(params[:scrap])
    @scrap.sender= sender
    @scrap.receiver= receiver
    @tab_action = params[:tab_action]
    @message = @scrap.save ? _("Message successfully sent.") : _("You can't leave an empty message.")
    @scraps = @profile.scraps_received.not_replies.paginate(:per_page => 30, :page => params[:page]) if params[:not_load_scraps].nil?
    render :partial => 'leave_scrap'
  end

  def view_more_scraps
    @scraps = @profile.scraps_received.not_replies.paginate(:per_page => 30, :page => params[:page])
    render :partial => 'profile_scraps', :locals => {:scraps => @scraps}
  end

  def view_more_activities
    @activities = @profile.tracked_actions.paginate(:per_page => 30, :page => params[:page])
    render :partial => 'profile_activities', :locals => {:activities => @activities}
  end

  def view_more_network_activities
    @activities = @profile.tracked_notifications.paginate(:per_page => 30, :page => params[:page]) 
    render :partial => 'profile_network_activities', :locals => {:network_activities => @activities}
  end

  def remove_scrap
    begin
      scrap = current_user.person.scraps(params[:scrap_id])
      scrap.destroy
      render :text => _('Scrap successfully removed.')
    rescue
      render :text => _('You could not remove this scrap')
    end
  end

  def remove_activity
    begin
      activity = current_person.tracked_actions.find(params[:activity_id])
      activity.destroy
      render :text => _('Activity successfully removed.')
    rescue
      render :text => _('You could not remove this activity')
    end
  end

  def profile_info
    begin
      @block = profile.blocks.find(params[:block_id])
    rescue
      render :text => _('Profile information could not be loaded')
    end
  end

  def report_abuse
    @abuse_report = AbuseReport.new
    render :layout => false
  end

  def register_report
    if !verify_recaptcha
      render :text => {
        :ok => false,
        :error => {
          :code => 1,
          :message => _('You could not answer the captcha.')
        }
      }.to_json
    else
      begin
        abuse_report = AbuseReport.new(params[:abuse_report])
        if !params[:content_type].blank?
          article = params[:content_type].constantize.find(params[:content_id])
          abuse_report.content = instance_eval(&article.reported_version)
        end

        user.register_report(abuse_report, profile)

        if !params[:content_type].blank?
          abuse_report = AbuseReport.find_by_reporter_id_and_abuse_complaint_id(user.id, profile.opened_abuse_complaint.id)
          Delayed::Job.enqueue DownloadReportedImagesJob.new(abuse_report, article)
        end

        render :text => {
          :ok => true,
          :message => _('Your abuse report was registered. The administrators are reviewing your report.'),
        }.to_json
      rescue Exception => exception
        logger.error(exception.to_s)
        render :text => {
          :ok => false,
          :error => {
            :code => 2,
            :message => _('Your report couldn\'t be saved due to some problem. Please contact the administrator.')
          }
        }.to_json
      end
    end
  end

  protected

  def check_access_to_profile
    unless profile.display_info_to?(user)
      redirect_to :action => 'index'
    end
  end

  def store_location
    if session[:previous_location].nil?
      session[:previous_location] = request.referer
    end
  end

  def redirect_to_previous_location
    back = session[:previous_location]
    if back
      session[:previous_location] = nil
      redirect_to back
    else
      redirect_to profile.url
    end
  end

  def private_profile
    if profile.person?
      @action = :add_friend
      @message = _("The content here is available to %s's friends only.") % profile.short_name
    else
      @action = :join
      @message = _('The contents in this community is available to members only.')
    end
    @no_design_blocks = true
  end

  def invisible_profile
    render_access_denied(_("This profile is inaccessible. You don't have the permission to view the content here."), _("Oops ... you cannot go ahead here"))
  end

  def per_page
    Noosfero::Constants::PROFILE_PER_PAGE
  end

  def members_per_page
    20
  end

end
