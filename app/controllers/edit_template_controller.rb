class EditTemplateController < ApplicationController

  design_editor :holder => 'virtual_community', :autosave => true
  
  def index
    redirect_to :action => 'design_editor'
  end

  FLEXIBLE_TEMPLATE_AVAILABLE_BLOCKS = {
    'ListBlock' => _("List Block"),
    'LinkBlock' => _("Link Block"),
  }


#TODO add your own helpers here
#  FLEXIBLE_TEMPLATE_BLOCK_HELPER = {
#      'list_content' => _("Simple List Content"),
#    }


end
