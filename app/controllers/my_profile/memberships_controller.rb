class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def leave
    @to_leave = Profile.find(params[:id])

    if request.post? && params[:confirmation]
      @to_leave.remove_member(profile)
      redirect_to :action => 'index'
    end
  end

  def new_community
    @community = Community.new(params[:community])
    if request.post?
      @community.environment = environment
      if @community.save
        @community.add_admin(profile)
        redirect_to :action => 'index'
      end
    end
  end

  def destroy_community
    @community = Community.find(params[:id])
    if request.post?
      if @community.destroy
        flash[:notice] = _('%s was destroyed!') % @community.short_name
        redirect_to :action => 'index'
      end
    end
  end

end
