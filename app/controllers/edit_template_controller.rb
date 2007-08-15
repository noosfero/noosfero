class EditTemplateController < ApplicationController

  design_editor :holder => 'virtual_community', :autosave => true, :block_types => :block_types, :block_helper_types => :block_helper_types
  
  def block_types
    { 
      'ListBlock' => _("List Block"), 
      'LinkBlock' => _("Link Block"),
      'Design::MainBlock' => _('Main content block'),
    }
  end

  # FIXME: is this really needed? Why should we let the user say how a
  # particular box must be displayed? IMO the box itself must have authority to
  # say how it wants to be drawn -- terceiro
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
