class ListBlockController < ApplicationController

  # This controller always has the object @design_block available to it.
  # The method acts_as_design_block load a before_filter that always load
  # this object.

  needs_profile

  acts_as_design_block

  # You must have a hash on format:
  #  {
  #    'action name' => 'How the action will be displayed on menu'
  #  }
  #
  # EX:
  #   CONTROL_ACTION_OPTIONS = {
  #     'design_edit' => _('Edit'),
  #     'manage_links' => _('Manage Links')
  #   }
  #
  # This hash will define the options menu on edit mode.
  CONTROL_ACTION_OPTIONS = {
    'edit' => _('Edit')
  } 


  ###########################
  # Mandatory methods
  ###########################  
  
  def index
    @people = @design_block.people
    design_render
  end
  
  ###########################
  # Other Sample of methods
  ###########################
 

  def edit
    design_render_on_edit :controller => 'list_block', :action => 'edit'
  end

  def save
    if @design_block.update_attributes(params[:design_block])
      design_render_on_edit :controller => 'list_block', :action => 'show'
    else
      design_render_on_edit :nothing => true
    end
  end

  def show
  end

end
