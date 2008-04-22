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
  
  def edit_categories
    @profile_object = profile
    if request.post?
      if profile.update_attributes(params[:profile_object])
        redirect_to :action => 'index'
      end
    end
  end

  private

  require 'erb'
  include ERB::Util
  def sanitize
    if params[:info]
      params[:info][:name] = html_escape(params[:info][:name]) if params[:info][:name]
      params[:info][:contact_person] = html_escape(params[:info][:contact_person]) if params[:info][:contact_person]
      params[:info][:acronym] = html_escape(params[:info][:acronym]) if params[:info][:acronym]
      params[:info][:legal_form] = html_escape(params[:info][:legal_form]) if params[:info][:legal_form]
      params[:info][:economic_activity] = html_escape(params[:info][:economic_activity]) if params[:info][:economic_activity]
      params[:info][:management_information] = html_escape(params[:info][:management_information]) if params[:info][:management_information]
    end
  end

end

