class EditTemplateController < AdminController
  
  design_editor :holder => 'environment', :autosave => true, :block_types => :block_types

  #FIXME This is wrong
  #See the FavoriteLinksController considerations and choose the better way
  def block_types
    %w[
       FavoriteLinks
     ]
  end

  def index
    redirect_to :action => 'design_editor'
  end

end
