class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :only => [:index, :edit]

  def index
    @pending_tasks = profile.tasks.pending
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    @profile_data = profile
    if request.post?
      profile.image || profile.build_image 
      if profile.update_attributes(params[:profile_data]) and profile.image.update_attributes(params[:image])
        redirect_to :action => 'index'
      end 
    end
  end

  def change_image
    @image = @profile.image ? @profile.image : @profile.build_image 
    if request.post?
      if @profile.image.update_attributes(params[:image])
        flash[:notice] = _('Image successfully uploaded')
        redirect_to :action => 'index'
      else
        flash[:notice] = _('Could not upload image')
        render :action => 'change_image'
      end
    end
  end
  
  def edit_categories
    @profile_object = profile
    if request.post?
      if profile.update_attributes(params[:profile_object])
        redirect_to :action => 'index'
      end
    end
  end

end

