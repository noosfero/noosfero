class EnterpriseEditorController < ProfileAdminController
  needs_profile
  protect 'edit_profile', :profile, :exept => :destroy
  protect 'destroy_profile', :profile, :only => :destroy
  
  before_filter :check_enterprise

  # Show details about an enterprise  
  def index
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
    #raise "bli"
    if @enterprise.destroy!
      flash[:notice] = _('Enterprise sucessfully erased from the system')
      redirect_to :controller => 'profile_editor', :action => 'index', :profile => current_user.login 
    else
      redirect_to :action => 'index'
    end
  end

  # Activate a validated enterprise
  def activate
    if @enterprise.activatepermission.nil?
      flash[:notice] = _('Enterprise successfuly activacted')
    else
      flash[:notice] = _('Failed to activate the enterprise')
    end
    redirect_to :action => 'index'
  end

  protected

  def permission
     'bli'
  end
  def permission=(perm)
    @p = perm
  end
  def check_enterprise
    if profile.is_a?(Enterprise)
      @enterprise = profile
    else 
      redirect_to :controller => 'account'  #:controller => 'profile_editor', :profile => current_user.login and return
    end
  end
end
