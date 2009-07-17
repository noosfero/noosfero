class AdminPanelController < AdminController

  before_filter :login_required
  
  protect 'view_environment_admin_panel', :environment

  def boxes_holder
    environment
  end

  def site_info
    if request.post?
      if @environment.update_attributes(params[:environment])
        redirect_to :action => 'index'
      end
    end
  end

  def set_portal_community
    env = environment
    @portal_community = env.portal_community || Community.new
    if request.post?
      portal_community = env.communities.find_by_identifier(params[:portal_community_identifier])
      if portal_community
        env.portal_community = portal_community
        env.save
        redirect_to :action => 'set_portal_folders'
      else
        flash[:notice] = __('Community not found. You must insert the identifier of a community from this environment')
      end
    end
  end

  def set_portal_folders
     @portal_folders = environment.portal_community.folders
     if request.post?
       env = environment
       folders = params[:folders].map{|fid| Folder.find(:first, :conditions => {:profile_id => env.portal_community, :id => fid})}
       env.portal_folders = folders
       if env.save
         flash[:notice] = _('Saved the portal folders')
         redirect_to :action => 'index'
       end
     end
     @selected = (environment.portal_folders || []).map(&:id)
  end
end
