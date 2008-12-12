class FeaturesController < AdminController
  protect 'edit_environment_features', :environment
  
  def index
    @features = Environment.available_features
  end

  post_only :update
  def update
    if @environment.update_attributes(params[:environment])
      flash[:notice] = _('Features updated successfully.')
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end

  def manage_fields
    @person_fields = Person.fields
    @enterprise_fields = Enterprise.fields
    @community_fields = Community.fields
  end

  def manage_person_fields
    environment.custom_person_fields = params[:person_fields]
    if environment.save!
      flash[:notice] = _('Custom person fields updated successfully.')
    else
      flash[:error] = _('Custom person fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_enterprise_fields
    environment.custom_enterprise_fields = params[:enterprise_fields]
    if environment.save!
      flash[:notice] = _('Custom enterprise fields updated successfully.')
    else
      flash[:error] = _('Custom enterprise fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_community_fields
    environment.custom_community_fields = params[:community_fields]
    if environment.save!
      flash[:notice] = _('Custom community fields updated successfully.')
    else
      flash[:error] = _('Custom community fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

end
