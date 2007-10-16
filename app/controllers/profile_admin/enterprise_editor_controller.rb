class EnterpriseEditorController < ProfileAdminController
  
  before_filter :login_required, :check_enterprise

  protect [:edit, :update], :edit_profile, :profile
  protect [:destroy], :destroy_profile, :profile

  needs_profile

  # Show details about an enterprise  
  def index
    @enterprise = @profile
  end

  # Provides an interface to editing the enterprise details
  def edit
    @validation_entities = Organization.find(:all) - [@enterprise]
  end

  # Saves the changes made in an enterprise
  def update
    if @enterprise.update_attributes(params[:enterprise]) && @enterprise.organization_info.update_attributes(params[:organization_info])
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Could not update the enterprise')
      @validation_entities = Organization.find(:all) - [@enterprise]
      render :action => 'edit'
    end
  end
  
  # Elimitates the enterprise of the system
  def destroy 
    @enterprise.destroy
    flash[:notice] = _('Enterprise sucessfully erased from the system')
    redirect_to '/'
  end

  # Activate a validated enterprise
  def activate
    if @enterprise.activate
      flash[:notice] = _('Enterprise successfuly activacted')
    else
      flash[:notice] = _('Failed to activate the enterprise')
    end
    redirect_to :action => 'index'
  end

  protected

  def check_enterprise
    redirect_to '/' unless @profile.is_a?(Enterprise)
    @enterprise = @profile
  end
end
