class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  
  def index
    @memberships = profile.memberships
  end

  def new_community
    community_data = environment.enabled?('organizations_are_moderated_by_default') ? { :moderated_articles => true } : {}
    community_data.merge!(params[:community]) if params[:community]
    @community = Community.new(community_data)
    @community.environment = environment
    @wizard = params[:wizard].blank? ? false : params[:wizard]
    if request.post?
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
