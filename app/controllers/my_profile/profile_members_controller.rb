class ProfileMembersController < MyProfileController
  protect 'manage_memberships', :profile
  no_design_blocks

  def index
    @members = profile.members
    @member_role = environment.roles.find_by_name('member')
  end

  def update_roles
    @roles = params[:roles] ? environment.roles.find(params[:roles]) : []
    @roles = @roles.select{|r| r.has_kind?('Profile') }
    @person = profile.members.find { |m| m.id == params[:person].to_i }
    if @person && @person.define_roles(@roles, profile)
      flash[:notice] = _('Roles successfuly updated')
    else
      flash[:notice] = _('Couldn\'t change the roles')
    end
    redirect_to :action => :index
  end
  
  def change_role
    @roles = profile.roles
    @member = profile.members.find { |m| m.id == params[:id].to_i }
    if @member
      @associations = @member.find_roles(@profile)
    else
      redirect_to :action => :index
    end
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
    render :layout => false
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
    render :layout => false
  end

  def add_members
  end

  def add_member
    if profile.enterprise?
      member = Person.find_by_identifier(params[:id])
      member.define_roles(Profile::Roles.all_roles(environment), profile)
    end
    render :layout => false
  end

  def find_users
    @users_found = Person.find_by_contents(params[:query])
    render :layout => false
  end

end
