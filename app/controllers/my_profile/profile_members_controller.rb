class ProfileMembersController < MyProfileController
  protect 'manage_memberships', :profile
  no_design_blocks

  def index
    @members = profile.members
    @member_role = environment.roles.find_by_name('member')
  end

  def update_roles
    @roles = params[:roles] ? environment.roles.find(params[:roles].select{|r|!r.to_i.zero?}) : []
    @roles = @roles.select{|r| r.has_kind?('Profile') }
    begin
      @person = profile.members.find(params[:person])
    rescue ActiveRecord::RecordNotFound
      @person = nil
    end
    if !params[:confirmation] && @person && @person.is_last_admin_leaving?(profile, @roles)
      redirect_to :action => :last_admin, :roles => params[:roles], :person => @person
    else
      if @person && @person.define_roles(@roles, profile)
        session[:notice] = _('Roles successfuly updated')
      else
        session[:notice] = _('Couldn\'t change the roles')
      end
      if params[:confirmation]
        redirect_to profile.url
      else
        redirect_to :action => :index
      end
    end
  end
  
  def last_admin
    @person = params[:person]
    @roles = params[:roles] || []
    @members = profile.members.select {|member| !profile.admins.include?(member)}
    @title = _('Current admins')
    @collection = :profile_admins
    @remove_action = {:action => 'remove_admin'}
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
      session[:notice] = 'Member succefully unassociated'
    else
      session[:notice] = 'Failed to unassociate member'
    end
    render :layout => false
  end

  def change_role
    @roles = Profile::Roles.organization_member_roles(environment.id)
    begin
      @member = profile.members.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @member = nil
    end
    if @member
      @associations = @member.find_roles(@profile)
    else
      redirect_to :action => :index
    end
  end

  def unassociate
    member = Person.find(params[:id])
    associations = member.find_roles(profile)
    RoleAssignment.transaction do
      if associations.map(&:destroy)
        session[:notice] = _('Member succesfully unassociated')
      else
        session[:notice] = _('Failed to unassociate member')
      end
    end
    render :layout => false
  end

  def add_members
  end

  def add_member
    if profile.enterprise?
      member = Person.find(params[:id])
      member.define_roles(Profile::Roles.all_roles(environment), profile)
    end
    render :layout => false
  end

  def add_admin
    @title = _('Current admins')
    @collection = :profile_admins

    if profile.community?
      member = profile.members.find_by_identifier(params[:id])
      profile.add_admin(member)
    end
    render :layout => false
  end

  def remove_admin
    @title = _('Current admins')
    @collection = :profile_admins

    if profile.community?
      member = profile.members.find_by_identifier(params[:id])
      profile.remove_admin(member)
    end
    render :layout => false
  end

  def find_users
    if !params[:query] || params[:query].length <= 2
      @users_found = []
    elsif params[:scope] == 'all_users'
      @users_found = Person.find_by_contents(params[:query] + '*').select {|user| !profile.members.include?(user)}
      @button_alt = _('Add member')
      @add_action = {:action => 'add_member'}
    elsif params[:scope] == 'new_admins'
      @users_found = Person.find_by_contents(params[:query] + '*').select {|user| profile.members.include?(user) && !profile.admins.include?(user)}
      @button_alt = _('Add member')
      @add_action = {:action => 'add_admin'}
    end
    render :layout => false
  end

  def send_mail
    @mailing = profile.mailings.build(params[:mailing])
    if request.post?
      @mailing.locale = locale
      @mailing.person = user
      if @mailing.save
        session[:notice] = _('The e-mails are being sent')
        redirect_to :action => 'index'
      else
        session[:notice] = _('Could not create the e-mail')
      end
    end
  end

end
