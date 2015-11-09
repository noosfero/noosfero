class PluginsController < AdminController
  protect 'edit_environment_features', :environment

  def index
    @active_plugins = Noosfero::Plugin.all.map {|plugin_name| plugin_name.constantize }.compact
  end

  post_only :update
  def update
    params[:environment][:enabled_plugins].delete('')
    if @environment.update(params[:environment])
      session[:notice] = _('Plugins updated successfully.')
    else
      session[:error] = _('Plugins were not updated successfully.')
    end
    redirect_to :action => 'index'
  end

end
