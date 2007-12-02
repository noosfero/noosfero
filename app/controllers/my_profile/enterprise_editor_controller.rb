class EnterpriseEditorController < MyProfileController
  protect 'edit_profile', :profile, :user, :except => :destroy
  protect 'destroy_profile', :profile, :only => :destroy
  
  requires_profile_class(Enterprise)
  before_filter :enterprise
  
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
    if @enterprise.destroy
      flash[:notice] = _('Enterprise sucessfully erased from the system')
      redirect_to :controller => 'profile_editor', :action => 'index', :profile => current_user.login 
    else
      redirect_to :action => 'index'
    end
  end

 protected

  def enterprise
    @enterprise = @profile
  end
end
