class EnvironmentRoleManagerController < AdminController
  protect 'manage_environment_roles', :environment

  def index
    @admins = Person.find(:all, :conditions => ['role_assignments.resource_type = ?', 'Environment'], :include => :role_assignments )
  end

  def change_roles
    @admin = Person.find(params[:id])
    @roles = Role.find(:all).select{ |r| r.has_kind?(:environment) }
  end

  def update_roles
    @roles = params[:roles] ? Role.find(params[:roles]) : []
    @person = Person.find(params[:person])
    if @person.define_roles(@roles, environment)
      session[:notice] = _('Roles successfuly updated')
    else
      session[:notice] = _('Couldn\'t change the roles')
    end
    redirect_to :action => :index
  end

  def change_role
    @roles = Role.find(:all).select{ |r| r.has_kind?(:environment) }
    @admin = Person.find(params[:id])
    @associations = @admin.find_roles(environment)
  end

  def add_role
    @person = Person.find(params[:person])
    @role = Role.find(params[:role])
    if environment.affiliate(@person, @role)
      redirect_to :action => 'index'
    else
      @admin = Person.find(params[:person])
      @roles = Role.find(:all).select{ |r| r.has_kind?(:environment) }
      render :action => 'affiliate'
    end
  end

  def remove_role
    @association = RoleAssignment.find(params[:id])
    if @association.destroy
      session[:notice] = _('Member succefully unassociated')
    else
      session[:notice] = _('Failed to unassociate member')
    end
    redirect_to :aciton => 'index'
  end

  def unassociate
    @association = RoleAssignment.find(params[:id])
    if @association.destroy
      session[:notice] = _('Member succefully unassociated')
    else
      session[:notice] = _('Failed to unassociate member')
    end
    redirect_to :aciton => 'index'
  end

  def make_admin
    @people = Person.find(:all)
    @roles = Role.find(:all).select{|r|r.has_kind?(:environment)}
  end
end
