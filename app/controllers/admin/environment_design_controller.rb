class EnvironmentDesignController < BoxOrganizerController
  
  def available_blocks
    @available_blocks ||= [ LoginBlock ]
  end

end
