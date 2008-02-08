class ManageCommunitiesController < MyProfileController

  def index
    @communities = profile.community_memberships
  end

  def new
    @community = Community.new(params[:community])
    if request.post?
      if @community.save
        @community.add_member(profile)
        redirect_to :action => 'index'
      end
    end
  end

end
