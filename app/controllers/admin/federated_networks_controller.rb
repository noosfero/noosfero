class FederatedNetworksController < AdminController
  protect 'edit_environment_features', :environment

  def index
    @networks = FederatedNetwork.all
  end

  def save_networks
    environment.update(params[:environment])
    redirect_to action: :index
    session[:notice] = _('Federated networks updated successfully.')
  end
end
