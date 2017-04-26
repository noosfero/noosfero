class EnvironmentDesignController < BoxOrganizerController

  protect 'edit_environment_design', :environment

  def available_blocks
    boxes_holder.available_blocks(user) + plugins.dispatch(:extra_blocks, :type => Environment)
  end

end
