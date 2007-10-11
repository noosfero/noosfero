class FeaturesController < EnvironmentAdminController

  acts_as_environment_admin_controller

  def index
    @features = Environment.available_features
  end

  post_only :update
  def update
    if @environment.update_attributes(params[:environment])
      flash[:notice] = _('Features updated successfully.')
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end

end
