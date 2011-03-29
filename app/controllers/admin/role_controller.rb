class RoleController < AdminController
  protect 'manage_environment_roles', :environment

  def index
    @roles = environment.roles.find(:all)
  end

  def show
    @role = environment.roles.find(params[:id])
  end

  def edit
    @role = environment.roles.find(params[:id])
  end

  def update
    @role = environment.roles.find(params[:id])
    if @role.update_attributes(params[:role])
      redirect_to :action => 'show', :id => @role
    else
      session[:notice] = _('Failed to edit role')
      render :action => 'edit'
    end
  end

end
