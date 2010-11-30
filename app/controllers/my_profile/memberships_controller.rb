class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def new_community
    @community = Community.new(params[:community])
    @community.environment = environment
    if request.post? && @community.valid?
      @community = Community.create_after_moderation(user, {:environment => environment}.merge(params[:community]))
      redirect_to :action => 'index'
      return
    end
  end
end
