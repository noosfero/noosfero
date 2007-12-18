class ProfileInfoBlockController < ApplicationController

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
    @info = @profile.info
    @can_edit = current_user.person.has_permission?('edit_profile', @profile)
    design_render
  end
  
  ###########################
  # Other Sample of methods
  ###########################
  
  def edit
    design_render_on_edit
  end
  
  def save
    @design_block.update_attributes(params[:design_block])
    design_render_on_edit :nothing => true
  end


end
