class PluginsController < AdminController

  def index
    @active_plugins = Noosfero::Plugin.all.map {|plugin_name| eval(plugin_name)}.compact
  end

  post_only :update
  def update
    params[:environment][:enabled_plugins].delete('')
    if @environment.update_attributes(params[:environment])
      session[:notice] = _('Plugins updated successfully.')
    else
      session[:error] = _('Plugins were not updated successfully.')
    end
    redirect_to :action => 'index'
  end

end
