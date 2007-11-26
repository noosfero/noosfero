class CmsController < MyProfileController
  
  # FIXME add the access control again
  # protect 'post_content', :profile, :only => [:edit, :new, :reorder, :delete]

  def view
    @document = profile.documents.find(params[:id])
  end

  protected

  def profile
    Profile.find_by_identifier(params[:profile]) 
  end

  def user
    current_user.person
  end


end
