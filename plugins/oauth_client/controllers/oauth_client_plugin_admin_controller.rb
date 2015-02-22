class OauthClientPluginAdminController < AdminController

  def index
  end

  def new
    @provider = environment.oauth_providers.new
    render :file => 'oauth_client_plugin_admin/edit'
  end

  def remove
    environment.oauth_providers.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def edit
    @provider = params[:id] ? environment.oauth_providers.find(params[:id]) : environment.oauth_providers.new
    if request.post?
      if @provider.update_attributes(params['oauth_client_plugin_provider'])
        session[:notice] = _('Saved!')
      else
        session[:notice] = _('Error!')
      end
    end
  end

end
