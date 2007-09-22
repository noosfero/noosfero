class FeaturesController < EnvironmentAdminController

  acts_as_environment_admin_controller

  def index
    @features = Environment.available_features
  end

  post_only :update
  def update
    features = if params[:features].nil?
                 []
               else
                 params[:features].keys
               end
    @environment.enabled_features = features
    @environment.save!
    flash[:notice] = _('Features updated successfully.')
    redirect_to :action => 'index'
  end

end
