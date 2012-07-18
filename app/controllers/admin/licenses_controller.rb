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
    @license = License.find(params[:license_id])
    if request.post?
      begin
        @license.update_attributes!(params[:license])
        session[:notice] = _('License updated')
        redirect_to :action => 'index'
      rescue
        session[:notice] = _('License could not be updated')
      end
    end
  end

  def remove
    @license = License.find(params[:license_id])
    begin
      @license.destroy
      session[:notice] = _('Licese removed')
    rescue
      session[:notice] = _('Licese could not be removed')
    end
    redirect_to :action => 'index'
  end

end
