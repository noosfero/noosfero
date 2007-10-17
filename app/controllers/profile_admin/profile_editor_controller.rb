class ProfileEditorController < ProfileAdminController
  helper :profile

  design_editor :holder => 'profile', :autosave => true, :block_types => :block_types

  def block_types
    {
      'ListBlock' => _("List Block"),
      'LinkBlock' => _("Link Block"),
      'Design::MainBlock' => _('Main content block'),
      'RecentDocumentsBlock' => _("Recent documents block")
    }
  end


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

