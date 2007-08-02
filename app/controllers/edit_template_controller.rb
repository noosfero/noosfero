class EditTemplateController < ApplicationController

  design_editor :holder => 'virtual_community', :autosave => true, :block_types => :block_types, :block_helper_types => :block_helper_types
  
  def block_types
    { 
      'ListBlock' => _("List Block"), 
      'LinkBlock' => _("Link Block"),
    }
  end

  def block_helper_types
    { 
      'list_content' => _("Simple List Content"), 
      'plain_content' => _("Link Block"),
    }
  end

  def index
    redirect_to :action => 'design_editor'
  end

end
