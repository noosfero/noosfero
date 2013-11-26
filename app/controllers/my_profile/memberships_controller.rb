class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def new_community
    @community = Community.new(params[:community])
    @community.environment = environment
    @back_to = params[:back_to] || url_for(:action => 'index')
    if request.post? && @community.valid?
      @community = Community.create_after_moderation(user, {:environment => environment}.merge(params[:community]))
      redirect_to @back_to
      return
    end
  end
end
