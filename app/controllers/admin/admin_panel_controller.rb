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

  def manage_templates
    @person_templates = environment.templates('person')
    @community_templates = environment.templates('community')
    @enterprise_templates = environment.templates('enterprise')
    @templates = @person_templates + @community_templates + @enterprise_templates
  end

  def set_template
    environment.person_template = Person.find(params[:environment][:person_template]) if params[:environment][:person_template]
    environment.enterprise_template = Enterprise.find(params[:environment][:enterprise_template]) if params[:environment][:enterprise_template]
    environment.community_template = Community.find(params[:environment][:community_template]) if params[:environment][:community_template]
    if environment.save!
      flash[:notice] = _('Template updated successfully')
    else
      flash[:error] = _('Could not update template')
    end
    redirect_to :action => 'manage_templates'
  end
end
