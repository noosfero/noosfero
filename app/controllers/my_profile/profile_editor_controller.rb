class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :only => [:index, :edit]

  def index
    @pending_tasks = profile.tasks.pending
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    if request.post?
      profile.info.update_attributes(params[:info])
      redirect_to :action => 'index'
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
end

