class AnalyticsPlugin::StatsController < MyProfileController

  no_design_blocks

  before_filter :skip_page_view

  def index
  end

  def edit
    return render_access_denied unless user.has_permission? 'edit_profile', profile

    params[:analytics_settings][:enabled] = params[:analytics_settings][:enabled] == 'true'
    params[:analytics_settings][:anonymous] = params[:analytics_settings][:anonymous] == 'true'
    @settings = profile.analytics_settings params[:analytics_settings] || {}
    @settings.save!
    render nothing: true
  end

  def view
    params[:profile_ids] ||= [profile.id]
    ids = params[:profile_ids].map(&:to_i)
    user.adminships # FIXME just to cache #adminship_ids
    ids = ids.select{ |id| id.in? user.adminship_ids } unless @user_is_admin

    @profiles = environment.profiles.find ids
    @user = environment.people.find params[:user_id]
    @visits = AnalyticsPlugin::Visit.eager_load(:users_page_views).
      where(profile_id: ids, analytics_plugin_page_views: {user_id: @user.id})

    render partial: 'table', locals: {visits: @visits}

  end

  protected

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

  def skip_page_view
    @analytics_skip_page_view = true
  end

end
