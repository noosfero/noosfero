class LicensesController < AdminController
  protect 'manage_environment_licenses', :environment

  def index
    @licenses = environment.licenses
  end

  def create
    @license = License.new(params[:license])
    if request.post?
      begin
        @license.environment = environment
        @license.save!
        session[:notice] = _('License created')
        redirect_to :action => 'index'
      rescue
        session[:notice] = _('License could not be created')
      end
    end
  end

  def edit
    @license = environment.licenses.find(params[:license_id])
    if request.post?
      begin
        @license.update!(params[:license])
        session[:notice] = _('License updated')
        redirect_to :action => 'index'
      rescue
        session[:notice] = _('License could not be updated')
      end
    end
  end

  def remove
    @license = environment.licenses.find(params[:license_id])
    if request.post?
      begin
        @license.destroy
        session[:notice] = _('License removed')
      rescue
        session[:notice] = _('License could not be removed')
      end
    else
      session[:notice] = _('License could not be removed')
    end
    redirect_to :action => 'index'
  end

end
