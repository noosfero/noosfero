class ExternalEnvironmentsController < AdminController
  protect 'edit_environment_features', :environment

  def index
    @environments = ExternalEnvironment.all
  end

  def save_environments
    environment.update(params[:environment])
    redirect_to action: :index
    session[:notice] = _('External environments updated successfully.')
  end
end
