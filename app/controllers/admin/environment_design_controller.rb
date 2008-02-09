class EnvironmentDesignController < BoxOrganizerController
  
  def available_blocks
    @available_blocks ||= [ LoginBlock, EnvironmentStatisticsBlock, RecentDocumentsBlock, ProfileListBlock ]
  end

end
