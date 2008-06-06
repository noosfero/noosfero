class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def join
    @to_join = Profile.find(params[:id])
    if request.post? && params[:confirmation]
      @to_join.add_member(profile)
      flash[:notice] = _('%s administrador still needs to accept you as member.') % @to_join.name if @to_join.closed?
      redirect_to @to_join.url
    end
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
      if @community.save
        @community.add_admin(profile)
        redirect_to :action => 'index'
      end
    end
  end

end
