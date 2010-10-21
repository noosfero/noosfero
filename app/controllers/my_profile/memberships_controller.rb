class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def new_community
    @wizard = params[:wizard].blank? ? false : params[:wizard]
    @community = Community.new(params[:community])
    @community.environment = environment
    if request.post? && @community.valid?
      @community = Community.create_after_moderation(user, {:environment => environment}.merge(params[:community]))
      if @wizard
        redirect_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true
        return
      else
        redirect_to :action => 'index'
        return
      end
    end
    if @wizard
      render :layout => 'wizard'
    end
  end
end
