class SiteTourPluginPublicController < PublicController

  before_filter :login_required

  def mark_action
    user.site_tour_plugin_actions += [params[:action_name]].flatten
    user.site_tour_plugin_actions.uniq!
    render :json => {:ok => user.save}
  end

end
