class EditTemplateController < EnvironmentAdminController
  
  design_editor :holder => 'environment', :autosave => true, :block_types => :block_types
  
  def block_types
    { 
      'ListBlock' => _("List Block"), 
      'LinkBlock' => _("Link Block"),
    }
  end

  def index
    redirect_to :action => 'design_editor'
  end

end
