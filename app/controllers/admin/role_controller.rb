class RoleController < AdminController
  protect 'manage_environment_roles', :environment

  def index
    @roles = environment.roles.find(:all, :conditions => {:profile_id => nil})
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new :name => params[:role][:name], :permissions => params[:role][:permissions], :environment => environment
    if @role.save
      redirect_to :action => 'show', :id => @role
    else
      session[:notice] = _('Failed to create role')
      render :action => 'new'
    end
  end

  def show
    @role = environment.roles.find(params[:id])
  end

  def edit
    @role = environment.roles.find(params[:id])
  end

  def update
    @role = environment.roles.find(params[:id])
    if @role.update(params[:role])
      redirect_to :action => 'show', :id => @role
    else
      session[:notice] = _('Failed to edit role')
      render :action => 'edit'
    end
  end

end
