class OpenGraphPlugin::MyprofileController < MyProfileController

  protect 'edit_profile', :profile
  before_filter :set_context

  def enterprise_search
    scope = environment.enterprises.enabled.public
    profile_search scope
  end
  def community_search
    scope = environment.communities.public
    profile_search scope
  end
  def friend_search
    scope = profile.friends
    profile_search scope
  end

  def track_config
    profile.update_attributes! params[:profile_data]
    render partial: 'track_form', locals: {context: context, reload: true}
  end

  protected

  def profile_search scope
    @query = params[:query]
    @profiles = scope.limit(10).order('name ASC').
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"])
    render partial: 'profile_search', locals: {profiles: @profiles}
  end

  def context
    :open_graph
  end

  def set_context
    OpenGraphPlugin.context = self.context
  end

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

end

