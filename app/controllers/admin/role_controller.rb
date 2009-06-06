class RoleController < AdminController
  protect 'manage_environment_roles', :environment

  def index
    @roles = environment.roles.find(:all)
  end

  def show
    @role = environment.roles.find(params[:id])
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    @role.environment = environment
    if @role.save
      redirect_to :action => 'show', :id => @role
    else
      flash[:notice] = _('Failed to create role')
      render :action => 'new'
    end
  end

  def edit
    @role = environment.roles.find(params[:id])
  end

  def update
    @role = environment.roles.find(params[:id])
    if @role.update_attributes(params[:role])
      redirect_to :action => 'show', :id => @role
    else
      flash[:notice] = _('Failed to edit role')
      render :action => 'edit'
    end
  end

  def destroy
    @role = environment.roles.find(params[:id])
    if @role.destroy
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Failed to edit role')
      redirect_to :action => 'index'
    end
  end
end
