class ProfileMembersController < MyProfileController
  protect 'manage_memberships', :profile

  def index
    @members = profile.members
  end

  def change_roles
    @member = Person.find(params[:id])
    @roles = Role.find(:all).select{ |r| r.has_kind?(:profile) }
  end  

  def update_roles
    @roles = params[:roles] ? Role.find(params[:roles]) : []
    @person = Person.find(params[:person])      
    if @person.define_roles(@roles, profile)
      flash[:notice] = _('Roles successfuly updated')
    else
      flash[:notice] = _('Couldn\'t change the roles')
    end
    redirect_to :action => :index
  end
  
  def change_role
    @roles = Role.find(:all).select{ |r| r.has_kind?(:profile) }
    @member = Person.find(params[:id])
    @associations = @member.find_roles(@profile)
  end

  def add_role
    @person = Person.find(params[:person])
    @role = Role.find(params[:role])
    if @profile.affiliate(@person, @role)
      redirect_to :action => 'index'
    else
      @member = Person.find(params[:person])
      @roles = Role.find(:all).select{ |r| r.has_kind?(:profile) }
      render :action => 'affiliate'
    end
  end

  def remove_role
    @association = RoleAssignment.find(params[:id])
    if @association.destroy
      flash[:notice] = 'Member succefully unassociated'
    else
      flash[:notice] = 'Failed to unassociate member'
    end
    redirect_to :aciton => 'index'
  end

  def unassociate
    @association = RoleAssignment.find(params[:id])
    if @association.destroy
      flash[:notice] = 'Member succefully unassociated'
    else
      flash[:notice] = 'Failed to unassociate member'
    end
    redirect_to :aciton => 'index'
  end
end
