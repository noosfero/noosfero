class ProfileRolesController < MyProfileController

  protect 'manage_custom_roles', :profile

  def index
    @roles = profile.custom_roles
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new({:name => params[:role][:name], :permissions => params[:role][:permissions], :environment => environment }, :without_protection => true)
    if @role.save
      profile.custom_roles << @role
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

  def assign_role_by_members
    return redirect_to "/" if params[:q].nil? or !request.xhr?
    arg = params[:q].downcase
    result = find_by_contents(:people, environment, profile.members, params[:q])[:results]
    render :text => prepare_to_token_input(result).to_json
  end

  def destroy
    @role = environment.roles.find(params[:id])
    @members = profile.members_by_role(@role)
    @roles_list = all_roles(environment, profile)
    @roles_list.delete(@role)
  end

  def remove
    @role = environment.roles.find(params[:id])
    @members = profile.members_by_role(@role)
    member_roles = params[:roles] ? environment.roles.find(params[:roles].select{|r|!r.to_i.zero?}) : []
    append_roles(@members, member_roles, profile)
    if @role.destroy
      session[:notice] = _('Role successfuly removed!')
    else
      session[:notice] = _('Failed to remove role!')
    end
    redirect_to :action => 'index'
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

  def assign
    @role = environment.roles.find(params[:id])
    @roles_list = all_roles(environment, profile)
    @roles_list.delete(@role)
  end

  def define
    @role = environment.roles.find(params[:id])
    selected_role = params[:selected_role] ? environment.roles.find(params[:selected_role].to_i) : nil
    if params[:assign_role_by].eql? "members"
      members_list = params[:person_id].split(',').collect {|id| environment.profiles.find(id.to_i)}
      members_list.collect{|person| person.add_role(@role, profile)}
    elsif params[:assign_role_by].eql? "roles"
      members = profile.members_by_role(selected_role)
      replace_role(members, selected_role, @role, profile)
    else
      session[:notice] = _("Error")
    end
    redirect_to :action => 'index'
  end

  protected

  def append_roles(members, roles, profile)
    members.each do |person|
      all_roles = person.find_roles(profile).map(&:role) + roles
      person.define_roles(all_roles, profile)
    end
  end

  def all_roles(environment, profile)
    Profile::Roles.organization_member_roles(environment.id) + profile.custom_roles
  end

  def replace_roles(members, roles, profile)
    members.each do |person|
      person.define_roles(roles, profile)
    end
  end

  def replace_role(members, role, new_role, profile)
    members.each do |person|
      person.remove_role(role, profile)
      person.add_role(new_role, profile)
    end
  end

end
