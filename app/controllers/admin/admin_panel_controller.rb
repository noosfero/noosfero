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

  def edit_templates
  end

end
