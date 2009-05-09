class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def leave
    @to_leave = Profile.find(params[:id])
    @wizard = params[:wizard]
    if request.post? && params[:confirmation]
      @to_leave.remove_member(profile)
      if @wizard
        redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
      else
        redirect_to :action => 'index'
      end
    end
  end

  def new_community
    @community = Community.new(params[:community])
    @wizard = params[:wizard].blank? ? false : params[:wizard]
    if request.post?
      @community.environment = environment
      if @community.save
        @community.add_admin(profile)
        if @wizard
           redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
          return
        else
          redirect_to :action => 'index'
          return
        end
      end
    end
    if @wizard
      render :layout => 'wizard'
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
