class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :only => [:index, :edit]

  helper :profile
  
  design_editor :holder => 'profile',:autosave => true, :block_types => :block_types


   def block_types
    %w[
       FavoriteLinksProfile
       ListBlock
       EnterprisesBlock
      ]
   end

# FIXME Put other Blocks to works
#  def block_types
#    {
#      'ListBlock' => _("List of People"),
#      'EnterprisesBlock' => _("List of Enterprises"),
#      'LinkBlock' => _("Link Block"),
#      'RecentDocumentsBlock' => _("Recent documents block")
#    }
#  end

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
        render :action => 'change_imange'
      end
    end
  end
end

