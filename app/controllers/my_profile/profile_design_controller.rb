class ProfileDesignController < BoxOrganizerController

  needs_profile

  def available_blocks
    @available_blocks ||= [ Block, ArticleBlock, TagsBlock ]
  end

end
