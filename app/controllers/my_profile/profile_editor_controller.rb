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
      if profile.update_attributes(params[:profile_data])
        redirect_to :action => 'index'
      end 
    end
  end

end

