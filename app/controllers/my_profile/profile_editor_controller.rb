class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :only => [:index, :edit]

  def index
    @pending_tasks = profile.tasks.pending
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    if request.post?
      if profile.update_attributes(params[:profile_data]) and profile.info.save
        redirect_to :action => 'index'
      end 
    else
      @info = profile.info
      render :action => @info.class.name.underscore
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

