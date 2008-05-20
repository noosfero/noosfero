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
      if profile.update_attributes(params[:profile_data])
        if !params[:image].blank? && !params[:image][:uploaded_data].blank? && !profile.image.update_attributes(params[:image])
          flash[:notice] = _('Could not upload image')
          return
        end
        redirect_to :action => 'index'
      end 
    end
  end

end

