class MapsController < MyProfileController

  protect 'edit_profile', :profile

  def edit_location
    @profile_data = profile
    if request.post?
      begin
        Profile.transaction do
          if profile.update_attributes!(params[:profile_data])
            session[:notice] = _('Address was updated successfully!')
            redirect_to :action => 'edit_location'
          end
        end
      rescue
        flash[:error] = _('Address could not be saved.')
      end
    end
  end

end
