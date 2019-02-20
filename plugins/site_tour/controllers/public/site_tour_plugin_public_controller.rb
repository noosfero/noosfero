class SiteTourPluginPublicController < PublicController

  before_action :login_required

  def mark_action
    user.site_tour_plugin_actions += [params[:action_name]].flatten
    user.site_tour_plugin_actions.uniq!
    render :json => {:ok => user.save}
  end
  alias :index :mark_action

end
