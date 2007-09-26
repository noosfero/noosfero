class EnterpriseEditorController < ProfileAdminController
  
  before_filter :logon, :check_enterprise
  protect [:edit, :update], :edit_profile, :profile
  protect [:destroy], :destroy_profile, @profile


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
    if @enterprise
      @enterprise.destroy
    else
      flash[:notice] = 'Can destroy only your enterprises'
    end
    redirect_to :action => 'index'
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

  def logon
    if logged_in?
      @user = current_user
      @person = @user.person
    end
  end

  def check_enterprise
    raise 'It\'s not an enterprise' unless @profile.is_a?(Enterprise)
    @enterprise = @profile
  end
end
