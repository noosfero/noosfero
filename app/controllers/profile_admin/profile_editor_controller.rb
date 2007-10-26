class ProfileEditorController < ProfileAdminController
#  protect [:index, :edit], 'edit_profile', :profile
  helper :profile
  
  needs_profile

  design_editor :holder => 'profile', :autosave => true, :block_types => :block_types


   def block_types
    %w[
       FavoriteLinks
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
end

