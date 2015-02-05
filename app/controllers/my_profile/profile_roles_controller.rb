class ProfileRolesController < MyProfileController

  include RoleHelper

  def index
    @roles = environment.roles.find(:all, :conditions => {:profile_id => profile.id} )
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.create({:name => params[:role][:name], :permissions => params[:role][:permissions], :profile_id => profile.id, :environment => environment }, :without_protection => true)
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

  def destroy
    @role = environment.roles.find(params[:id])
    @members = profile.members_by_role(@role)
    @roles_list = Profile::Roles.organization_all_roles(environment.id, profile.id)
    @roles_list.delete(@role)
  end

  def remove
    @role = environment.roles.find(params[:id])
    @members = profile.members_by_role(@role)
    new_roles = params[:roles] ? environment.roles.find(params[:roles].select{|r|!r.to_i.zero?}) : []
    @members.each do |person|
      member_roles = person.find_roles(profile).map(&:role) + new_roles
      person.define_roles(member_roles, profile)
    end
    if @role.destroy
      session[:notice] = _('Role successfuly removed!')
    else
      session[:notice] = _('Failed to remove role!')
    end
    redirect_to :action => 'index'
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
