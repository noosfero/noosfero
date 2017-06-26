class ProfileController < PublicController

  needs_profile
  before_filter :check_access_to_profile, :except => [:join, :join_not_logged, :index, :add]
  before_filter :store_location, :only => [:join, :join_not_logged, :report_abuse, :send_mail]
  before_filter :login_required, :only => [:add, :join, :leave, :unblock, :leave_scrap, :remove_scrap, :remove_activity, :view_more_activities, :view_more_network_activities, :report_abuse, :register_report, :leave_comment_on_activity, :send_mail, :follow, :unfollow]
  before_filter :allow_followers?, :only => [:follow, :unfollow]
  before_filter :accept_only_post, :only => [:follow, :unfollow]
  before_filter :allow_scrap?, :only => [:leave_scrap]
  before_filter :allow_comment?, :only => [:leave_comment_on_activity]
  before_filter :load_tags, only: [:index, :about]

  include ProfileHelper
  helper TagsHelper
  helper ActionTrackerHelper
  helper CustomFieldsHelper

  include Captcha

  protect 'send_mail_to_members', :profile, :only => [:send_mail]

  ACTIVITIES_PER_PAGE = 15

  def index
    @offsets = {:wall => 0, :network => 0}
    page = (params[:page] || 1).to_i
    if logged_in?
      @activities = loop_fetch_activities(@profile.activities, :wall, page) if AccessLevels.can_access?(@profile.wall_access, user, @profile)
      @network_activities = loop_fetch_activities(@profile.tracked_notifications, :network, page) if @profile == user
    end
    allow_access_to_page
  end

  def about
  end

  def activities
    @offsets = {:wall => 0, :network => 0}
    page = (params[:page] || 1).to_i
    @activities = loop_fetch_activities(@profile.activities, :wall, page) if AccessLevels.can_access?(@profile.wall_access, user, @profile)
  end

  def tags
    @tags_cache_key = "tags_profile_#{profile.id.to_s}"
    if is_cache_expired?(@tags_cache_key)
      @tags = profile.article_tags
    end
  end

  def content_tagged
    @tag = params[:id]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_#{profile.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key)
      @tagged = profile.articles.tagged_with(@tag).paginate(:per_page => 20, :page => params[:npage])
    end
  end

  def tag_feed
    @tag = params[:id]
    tagged = profile.articles.paginate(:per_page => 20, :page => 1).order('published_at DESC').joins(:tags).where('tags.name LIKE ?', @tag)
    feed_writer = FeedWriter.new
    data = feed_writer.write(
      tagged,
      :title => _("%s's contents tagged with \"%s\"").html_safe % [profile.name, @tag],
      :description => _("%s's contents tagged with \"%s\"").html_safe % [profile.name, @tag],
      :link => url_for(profile.url)
    )
    render :text => data, :content_type => "text/xml"
  end

  def communities
    if is_cache_expired?(profile.communities_cache_key(params))
      @communities = profile.communities.includes(relations_to_include).paginate(:per_page => per_page, :page => params[:npage], :total_entries => profile.communities.count)
    end
  end

  def enterprises
    @enterprises = profile.enterprises.includes(relations_to_include)
  end

  def friends
    if is_cache_expired?(profile.friends_cache_key(params))
      @friends = profile.friends.order(:name).includes(relations_to_include)
        .paginate(:per_page => per_page, :page => params[:npage],
                  :total_entries => profile.friends.count)
    end
  end

  def following
    @followed_people = profile.followed_profiles.paginate(:per_page => per_page, :page => params[:npage], :total_entries => profile.followed_profiles.count)
  end

  def followed
    @followed_by = profile.followers.paginate(:per_page => per_page, :page => params[:npage], :total_entries => profile.followers.count)
  end

  def members
    if is_cache_expired?(profile.members_cache_key(params))
      sort = (params[:sort] == 'desc') ? params[:sort] : 'asc'
      @profile_admins = profile.admins.includes(relations_to_include).order("name #{sort}").paginate(:per_page => members_per_page, :page => params[:npage])
      @profile_members = profile.members.includes(relations_to_include).order("name #{sort}").paginate(:per_page => members_per_page, :page => params[:npage])
      @profile_members_url = url_for(:controller => 'profile', :action => 'members')
    end
  end

  def fans
    @fans = profile.fans.includes(relations_to_include)
  end

  def favorite_enterprises
    @favorite_enterprises = profile.favorite_enterprises.includes(relations_to_include)
  end

  def sitemap
    @articles = profile.top_level_articles.includes([:profile, :parent])
  end

  def join_modal
      profile.add_member(user)
      session[:notice] = _('%s administrator still needs to accept you as member.').html_safe % profile.name
      redirect_to :action => :index
  end

  def join
    if !user.memberships.include?(profile)
      return if profile.community? && show_confirmation_modal?(profile)

      profile.add_member(user)
      if !profile.members.include?(user)
        render :text => {:message => _('%s administrator still needs to accept you as member.').html_safe % profile.name}.to_json
      else
        render :text => {:message => _('You just became a member of %s.').html_safe % profile.name}.to_json
      end
    else
      render :text => {:message => _('You are already a member of %s.').html_safe % profile.name}.to_json
    end
  end

  def join_not_logged
    session[:join] = profile.identifier

    if user
      redirect_to :controller => 'profile', :action => 'join'
    else
      redirect_to :controller => '/account', :action => 'login', :return_to => profile.url
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
      render :text => {:message => _('You are not a member of %s.').html_safe % profile.name}.to_json
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
      render :text => _('%s still needs to accept being your friend.').html_safe % profile.name
    else
      render :text => _('You are already a friend of %s.').html_safe % profile.name
    end
  end

  def follow
    if profile.followed_by?(current_person)
      render :text => _("You are already following %s.") % profile.name, :status => 400
    else
      selected_circles = params[:circles].map{ |circle_name, circle_id| Circle.find_by(:id => circle_id) }.select{ |c| c.present? }
      if selected_circles.present?
        current_person.follow(profile, selected_circles)
        render :text => _("You are now following %s") % profile.name, :status => 200
      else
        render :text => _("Select at least one circle to follow %s.") % profile.name, :status => 400
      end
    end
  end

  def find_profile_circles
    circles = Circle.where(:person => current_person, :profile_type => profile.class.name)
    render :partial => 'blocks/profile_info_actions/circles', :locals => { :circles => circles, :profile_types => Circle.profile_types.to_a }
  end

  def unfollow
    follower = params[:follower_id].present? ? Person.find_by(id: params[:follower_id]) : current_person

    if follower && follower.follows?(profile)
      follower.unfollow(profile)
    end
    redirect_url = params["redirect_to"] ? params["redirect_to"] : profile.url
    redirect_to redirect_url
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

  def follow_article
    article = profile.environment.articles.find params[:article_id]
    article.person_followers << user
    redirect_to article.url
  end

  def unfollow_article
    article = profile.environment.articles.find params[:article_id]
    article.person_followers.delete(user)
    redirect_to article.url
  end

  def unblock
    if current_user.person.is_admin?(profile.environment)
      profile.unblock
      session[:notice] = _("You have unblocked %s successfully. ").html_safe % profile.name
      redirect_to :controller => 'profile', :action => 'index'
    else
      message = _('You are not allowed to unblock enterprises in this environment.')
      render_access_denied(message)
    end
  end

  def leave_scrap
    sender = params[:sender_id].nil? ? current_user.person : Person.find(params[:sender_id])
    receiver = params[:receiver_id].nil? ? @profile : Person.find(params[:receiver_id])
    @scrap = Scrap.new(params[:scrap])
    @scrap.sender= sender
    @scrap.receiver= receiver
    @scrap.marked_people = treat_followed_entries(params[:filter_followed])
    @tab_action = params[:tab_action]
    @message = @scrap.save ? _("Message successfully sent.") : _("You can't leave an empty message.")
    activities = @profile.activities.paginate(:per_page => 15, :page => params[:page]) if params[:not_load_scraps].nil?
    render :partial => 'profile_activities_list', :locals => {:activities => activities}
  end

  def leave_comment_on_activity
    @comment = Comment.new(params[:comment])
    @comment.author = user
    @activity = ActionTracker::Record.find(params[:source_id])
    @comment.source_type, @comment.source_id = (@activity.target_type == 'Article' ? ['Article', @activity.target_id] : [@activity.class.to_s, @activity.id])
    @tab_action = params[:tab_action]
    @message = @comment.save ? _("Comment successfully added.") : _("You can't leave an empty comment.")
    if @tab_action == 'wall'
      activities = @profile.activities.paginate(:per_page => 15, :page => params[:page]) if params[:not_load_scraps].nil?
      render :partial => 'profile_activities_list', :locals => {:activities => activities}
    else
      network_activities = @profile.tracked_notifications.visible.paginate(:per_page => 15, :page => params[:page])
      render :partial => 'profile_network_activities', :locals => {:activities => network_activities}
    end
  end

  def search_followed
    result = []
    circles = find_by_contents(:circles, user, user.circles.where(:profile_type => 'Person'), params[:q])[:results]
    followed = find_by_contents(:followed, user, Profile.followed_by(user), params[:q])[:results]
    result = circles + followed
    render :text => prepare_to_token_input_by_class(result).to_json
  end

  def loop_fetch_activities(base_activities, kind, page)
    activities = nil
    while activities.nil? || (activities.empty? && page <= activities.total_pages)
      activities = base_activities.offset(@offsets[kind.to_sym]).paginate(:per_page => ACTIVITIES_PER_PAGE, :page => page)
      activities = filter_activities(activities, kind.to_sym)
      page += 1
    end
    activities
  end

  def view_more_activities
    @activities = nil
    @offsets = params[:offsets]
    page = (params[:page] || 1).to_i
    kind = params[:kind]

    if kind == 'wall'
      base_activities = @profile.activities
      partial = 'profile_activities_list'
    else
      base_activities = @profile.tracked_notifications
      partial = 'profile_network_activities'
    end

    @activities = loop_fetch_activities(base_activities, kind, page)
    render :partial => partial, :locals => {:activities => @activities}
  end

  def more_comments
    profile_filter = @profile.person? ? {:user_id => @profile} : {:target_id => @profile}
    activity = ActionTracker::Record.where(:id => params[:activity])
    activity = activity.where(profile_filter) if !logged_in? || !current_person.follows?(@profile)
    activity = activity.first

    comments_count = activity.comments.count
    comment_page = (params[:comment_page] || 1).to_i
    comments_per_page = 5
    no_more_pages = comments_count <= comment_page * comments_per_page

    update_feed(comments_count, comment_page, comments_per_page, no_more_pages, activity)
  end

  def more_replies
    activity = Scrap.where(:id => params[:activity], :receiver_id => @profile, :scrap_id => nil).first
    comments_count = activity.replies.count
    comment_page = (params[:comment_page] || 1).to_i
    comments_per_page = 5
    no_more_pages = comments_count <= comment_page * comments_per_page

    render :update do |page|
      page.insert_html :bottom, 'profile-wall-activities-comments-'+params[:activity],
        :partial => 'profile_scrap', :collection => activity.replies.paginate(:per_page => comments_per_page, :page => comment_page), :as => :scrap

      if no_more_pages
        page.remove 'profile-wall-activities-comments-more-'+params[:activity]
      else
        page.replace_html 'profile-wall-activities-comments-more-'+params[:activity],
          :partial => 'more_replies', :locals => {:activity => activity, :comment_page => comment_page}
      end
    end
  end

  def remove_scrap
    begin
      scrap = current_user.person.scraps(params[:scrap_id])
      scrap.destroy
      finish_successful_removal 'Scrap successfully removed.'
    rescue
      finish_unsuccessful_removal 'You could not remove this scrap.'
    end
  end

  def remove_activity
    begin
      raise if !can_edit_profile
      activity = ActionTracker::Record.find(params[:activity_id])
      if params[:only_hide]
        activity.update_attribute(:visible, false)
      else
        activity.destroy
      end
      finish_successful_removal 'Activity successfully removed.'
    rescue
      finish_unsuccessful_removal 'You could not remove this activity.'
    end
  end

  def remove_notification
    begin
      raise if !can_edit_profile
      notification = ActionTrackerNotification.where(profile_id: profile.id, action_tracker_id: params[:activity_id]).first
      notification.destroy
      render :text => _('Notification successfully removed.')
    rescue
      render :text => _('You could not remove this notification.')
    end
  end

  def finish_successful_removal(msg)
    if request.xhr?
      render :text => {'ok' => true}.to_json, :content_type => 'application/json'
    else
      session[:notice] = _(msg)
      redirect_to :action => :index
    end
  end

  def finish_unsuccessful_removal(msg)
    session[:notice] = _(msg)
    if request.xhr?
      render :text => {'redirect' => url_for(:action => :index)}.to_json, :content_type => 'application/json'
    else
      redirect_to :action => :index
    end
  end

  def report_abuse
    @abuse_report = AbuseReport.new
    render :layout => false
  end

  def register_report
    unless verify_captcha(:report_abuse, nil, user, environment, profile)
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
          abuse_report.content = article_reported_version(article)
        end

        user.register_report(abuse_report, profile)

        if !params[:content_type].blank?
          abuse_report = AbuseReport.find_by(reporter_id: user.id, abuse_complaint_id: profile.opened_abuse_complaint.id)
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

  def remove_comment
    #FIXME Check whether these permissions are enough
    @comment = Comment.find(params[:comment_id])
    if (user == @comment.author || user == profile || user.has_permission?(:moderate_comments, profile))
      @comment.destroy
      finish_successful_removal 'Comment successfully removed.'
    else
      finish_unsuccessful_removal 'You could not remove this comment.'
    end
  end

  def send_mail
    @mailing = profile.mailings.build(params[:mailing])
    @mailing.data = session[:members_filtered] ? {:members_filtered => session[:members_filtered]} : {}
    @email_templates = profile.email_templates.where template_type: :organization_members
    if request.post?
      @mailing.locale = locale
      @mailing.person = user
      if @mailing.save
        session[:notice] = _('The e-mails are being sent')
        redirect_to_previous_location
      else
        session[:notice] = _('Could not create the e-mail')
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

  def per_page
    Noosfero::Constants::PROFILE_PER_PAGE
  end

  def members_per_page
    20
  end

  def can_edit_profile
    @can_edit_profile ||= user && user.has_permission?('edit_profile', profile)
  end
  helper_method :can_edit_profile

  def relations_to_include
    [:image, :domains, :preferred_domain, :environment]
  end

  def allow_followers?
    render_not_found unless profile.allow_followers?
  end

  def treat_followed_entries(entries)
    return [] if entries.blank? || profile != user

    followed = []
    entries.split(',').map do |entry|
      klass, identifier = entry.split('_')
      case klass
      when 'Person'
        followed << Person.find(identifier)
      when 'Circle'
        circle = Circle.find(identifier)
        followed += Profile.in_circle(circle)
      end
    end
    followed.uniq
  end

  def filter_activities(activities, kind)
    @offsets ||= {:wall => 0, :network => 0}
    return activities if environment.admins.include?(user)
    activities = Array(activities)
    initial_count = activities.count
    activities.delete_if do |activity|
      activity = ActivityPresenter.for(activity)
      next if activity.involved?(user)
      activity.hidden_for?(user)
    end
    @offsets[kind] = @offsets[kind].to_i
    @offsets[kind] += initial_count - activities.count
    activities
  end

  def follow_profile?
    logged_in? && current_person.follows?(@profile)
  end

  def allow_scrap?
    logged_in? && (current_person == @profile || (current_person.is_member_of?(@profile) || current_person.is_a_friend?(@profile)))
  end
  helper_method :allow_scrap?

  def allow_comment?
    logged_in?
  end
  helper_method :allow_comment?

  def load_tags
    @tags = profile.article_tags
  end
end
