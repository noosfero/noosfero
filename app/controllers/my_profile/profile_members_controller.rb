class ProfileMembersController < MyProfileController
  protect 'manage_memberships', :profile

  def index
    @members = profile.members
    @member_role = environment.roles.find_by_name('member')
  end

  def update_roles
    @roles = params[:roles] ? environment.roles.find(params[:roles]) : []
    @roles = @roles.select{|r| r.has_kind?('Profile') }
    @person = Person.find(params[:person])      
    if @person.define_roles(@roles, profile)
      flash[:notice] = _('Roles successfuly updated')
    else
      flash[:notice] = _('Couldn\'t change the roles')
    end
    redirect_to :action => :index
  end
  
  def change_role
    @roles = profile.roles
    @member = Person.find(params[:id])
    @associations = @member.find_roles(@profile)
  end

  def add_role
    @person = Person.find(params[:person])
    @role = environment.roles.find(params[:role])
    if @profile.affiliate(@person, @role)
      redirect_to :action => 'index'
    else
      @member = Person.find(params[:person])
      @roles = environment.roles.find(:all).select{ |r| r.has_kind?('Profile') }
      render :action => 'affiliate'
    end
  end

  def remove_role
    @association = RoleAssignment.find(:all, :conditions => {:id => params[:id], :target_id => profile.id})
    if @association.destroy
      flash[:notice] = 'Member succefully unassociated'
    else
      flash[:notice] = 'Failed to unassociate member'
    end
    redirect_to :aciton => 'index'
  end

  def unassociate
    member = Person.find(params[:id])
    associations = member.find_roles(profile)
    RoleAssignment.transaction do
      if associations.map(&:destroy)
        flash[:notice] = 'Member succefully unassociated'
      else
        flash[:notice] = 'Failed to unassociate member'
      end
    end
    redirect_to :action => 'index'
  end

end
