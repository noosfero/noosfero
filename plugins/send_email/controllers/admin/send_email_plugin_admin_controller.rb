class SendEmailPluginAdminController < PluginsController

  def index
    @environment = environment
    if request.post?
      if environment.update(params[:environment])
        session[:notice] = _('Configurations was saved')
        redirect_to :controller => 'plugins'
      else
        session[:notice] = _('Configurations could not be saved')
      end
    end
  end

end
